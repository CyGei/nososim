#' Simulate an outbreak
#'
#' Simulates nosocomial outbreaks. Each individual can be infected once,
#' and new cases become infectious from the following day.
#'
#' @param timeline A population timeline from [make_timeline()].
#' @param imported Data frame with `id` and `date` (infection date) for imported cases.
#' @param w Probability mass function of the generation time distribution.
#' @param dates Dates over which to simulate transmission.
#' @param intervention Function of `present` and `date` returning the matrix
#'   E(t) of proportional hazard reductions (0 = none, 1 = complete),
#'   as defined in METHODS.md, Interventions. Rows represent
#'   sources and columns recipients. `present` contains the daily
#'   population, infection status, infection age, and infectiousness.
#' @param mixing Named list of mixing matrices by population attribute.
#'   Rows represent source groups and columns recipient groups.
#'   Weights are multiplied across attributes. `NULL` assumes equal mixing.
#'
#' @return A `nososim_outbreak` containing the population timeline,
#'   infection records (`id`, `source`, `date_infection`), simulation
#'   dates, and parameters. Imported cases have `NA` sources.
#'
#'
#' @export
#' @examples
#' dates <- as.Date("2026-01-01") + 0:6
#' timeline <- make_timeline(10, dates, stay = 7,
#' attributes = list(
#'  ward = c(A = 0.5, B = 0.5),
#' group = c(patient = 0.8, staff = 0.2)
#' ))
#'
#' imported <- data.frame(id = "ID_1", date = dates[1])
#'
#' global_ipc <- function(present, date) {
#'   E_t <- matrix(
#'     0, nrow(present), nrow(present),
#'     dimnames = list(present$id, present$id)
#'   )
#'   if (date >= dates[4]) E_t[,] <- 0.9
#'   E_t
#' }
#'
#' staff_masking <- function(present, date) {
#'   E_t <- matrix(
#'     0, nrow(present), nrow(present),
#'     dimnames = list(present$id, present$id)
#'   )
#'   E_t[present$group == "staff", ] <- 0.9
#'   E_t
#' }
#'
#' A_to_B_IPC <- function(present, date) {
#'   E_t <- matrix(
#'     0, nrow(present), nrow(present),
#'     dimnames = list(present$id, present$id)
#'   )
#'   E_t[present$ward == "A", present$ward == "B"] <- 0.9
#'   E_t
#' }
#'
#' make_outbreak(timeline, imported, w = c(0.2, 0.5, 0.3),
#'   dates, intervention = A_to_B_IPC
#' )

make_outbreak <- function(
  timeline,
  imported,
  w,
  dates,
  intervention,
  mixing = NULL
) {
  if (!is.function(intervention)) {
    stop("`intervention` must be a function of `present` and `date`.")
  }

  if (anyDuplicated(timeline[c("id", "date")])) {
    stop("`timeline` must have at most one row per ID and date.")
  }

  if (!is.data.frame(imported) || !all(c("id", "date") %in% names(imported))) {
    stop("`imported` must be a data frame with `id` and `date` columns.")
  }

  imported <- tibble::as_tibble(imported)
  dates <- sort(dates)
  infections <- imported |>
    transmute(id, date_infection = date) |>
    arrange(date_infection, id) |>
    mutate(source = NA_character_)

  for (i in seq_along(dates)) {
    date <- dates[i]
    present <- timeline |>
      filter(date == .env$date) |>
      arrange(id) |>
      left_join(infections, by = "id") |>
      mutate(
        # w[1] is the first day after infection; other lags contribute zero.
        age = as.integer(.env$date - date_infection),
        lambda = coalesce(R_i * .env$w[match(age, seq_along(.env$w))], 0)
      )

    # METHODS.md: pairwise mixing, intervention E(t), and hazards h_ij(t).
    m_t <- mixing_matrix(present, mixing)
    E_t <- intervention(present, date)
    h_t <- transmission_hazards(present, m_t, E_t)

    new <- present |>
      mutate(p = -expm1(-colSums(.env$h_t))) |>
      filter(is.na(date_infection)) |>
      filter(rbinom(n(), 1, p) == 1) |>
      transmute(
        id,
        source = map_chr(id, \(recipient) {
          contributions <- .env$h_t[, recipient]
          sample(
            rownames(.env$h_t)[contributions > 0],
            1,
            prob = contributions[contributions > 0]
          )
        }),
        date_infection = .env$date
      )

    # Apply infections together, so new cases first transmit the following day.
    infections <- bind_rows(infections, new)
  }

  infections <- infections |>
    arrange(date_infection, id) |>
    select(id, source, date_infection)

  structure(
    list(
      timeline = timeline,
      infections = infections,
      dates = dates,
      parameters = list(
        imported = imported,
        w = w,
        mixing = mixing,
        intervention = intervention
      )
    ),
    class = "nososim_outbreak"
  )
}

#' @export
#' @noRd
print.nososim_outbreak <- function(x, ...) {
  cat("<nososim_outbreak>\n")
  print(summary(x), ...)
  invisible(x)
}

#' Build the daily mixing matrix
#'
#' @param present Daily population with `id` and mixing attribute columns.
#' @inheritParams make_outbreak
#' @return A matrix named by ID: source rows and recipient columns.
#' @noRd
mixing_matrix <- function(present, mixing = NULL) {
  mixing |>
    imap(\(weights, column) {
      values <- as.character(present[[column]])
      weights[values, values, drop = FALSE]
    }) |>
    reduce(
      \(x, y) x * y,
      .init = matrix(
        1,
        nrow(present),
        nrow(present),
        dimnames = list(present$id, present$id)
      )
    )
}

#' Calculate daily transmission hazards
#'
#' @param present Daily population with `id` and `lambda` (infectiousness).
#' @param m_t Pairwise mixing weights m_ij(t), named by ID. Source rows and
#'   recipient columns; self-contact is removed before normalisation.
#' @param E_t Intervention matrix E(t) with reductions between 0 and 1, named by
#'   present IDs. See METHODS.md, Interventions.
#' @return The hazard matrix h_ij(t), named by ID, with zero self-contact. Reductions apply
#'   after row normalisation, without redistributing prevented transmission.
#' @noRd
transmission_hazards <- function(present, m_t, E_t) {
  if (
    !is.matrix(E_t) ||
      !is.numeric(E_t) ||
      !identical(dim(E_t), c(nrow(present), nrow(present)))
  ) {
    stop(
      "`intervention` must return a numeric matrix with one row and column per ID present."
    )
  }
  if (
    !setequal(rownames(E_t), present$id) ||
      !setequal(colnames(E_t), present$id)
  ) {
    stop("Intervention matrix row and column names must match the IDs present.")
  }
  if (any(!is.finite(E_t)) || any(E_t < 0 | E_t > 1)) {
    stop("Intervention reductions must be finite values between 0 and 1.")
  }

  E_t <- E_t[present$id, present$id, drop = FALSE]
  m_t <- m_t[present$id, present$id, drop = FALSE]
  # METHODS.md, Distribution of infectiousness: m_ii(t) = 0.
  diag(m_t) <- 0
  total <- rowSums(m_t)
  q_t <- m_t / if_else(total > 0, total, 1)

  # METHODS.md, Interventions: h_ij(t) = lambda_i(t) q_ij(t) [1 - e_ij(t)].
  q_t * present$lambda * (1 - E_t)
}
