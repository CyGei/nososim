#' Simulate a contact-driven outbreak
#'
#' Each person can be infected once. Uses [simulacr::simulate_outbreak_step()]
#' to advance the epidemic from each contact date to the following day.
#' Contact intensities multiply transmission rates without normalisation.
#'
#' @param population Population records with `id`, `start`, `end`, and contact
#'   attributes. Repeated IDs represent separate stays or shifts; records for
#'   the same person must not overlap. IDs are stored as character strings.
#' @param imported Data frame with `id` and `date_infection` for imported cases.
#'   Cases before the first simulation day initialise infection history. Later
#'   imports occur on their date, unless the person has already been infected.
#' @param w Generation-time PMF accepted by [simulacr::make_pmf_delay()]: a
#'   function, a `distcrete` object, or numeric weights on delays 0, 1, etc.
#'   Numeric weights are normalised; the first weight applies at delay zero.
#' @param dates Consecutive daily contact dates. Contacts on date `t` produce
#'   infections dated `t + 1`, including the day after the final contact date.
#' @param contacts Function `(present, date)` returning a non-negative contact
#'   matrix, with source IDs in rows and recipient IDs in columns. May be
#'   asymmetric. Self-contact is set to zero.
#' @param tau Function `(present, date)` returning one finite, non-negative
#'   transmission rate per person, in row order. Defaults to the `tau` column.
#' @param intervention Optional function `(present, date)` returning a matrix
#'   of proportional hazard reductions, named by ID (0 = none, 1 = complete).
#'   `present` includes infection dates, `infection_age`, current `tau`, and
#'   `infectiousness`. `NULL` applies no reduction.
#' @return A `nososim_outbreak` containing `population`, `infections` (`id`,
#'   `source`, `date_infection`), `dates`, `parameters`, and `reproduction`.
#'   Imported cases have `NA` sources. `reproduction` contains each person's
#'   summed outgoing FOI (`R_i`, equation 12), including intervention effects.
#'   This differs from realised secondary infections counted by [offspring()].
#' @export
#' @examples
#' dates <- as.Date("2026-01-01") + 0:6
#' population <- tibble::tibble(
#'   id = c("a", "b", "c"), level_1 = "hospital",
#'   start = dates[1], end = dates[7], tau = 0.5
#' )
#' make_outbreak(
#'   population, data.frame(id = "a", date_infection = dates[1]),
#'   w = c(0.2, 0.5, 0.3), dates = dates, contacts = get_contacts
#' )
make_outbreak <- function(
  population,
  imported,
  w,
  dates,
  contacts,
  tau = population_tau,
  intervention = NULL
) {
  population <- tibble::as_tibble(population) |>
    mutate(id = as.character(id))
  imported <- tibble::as_tibble(imported) |>
    transmute(id = as.character(id), source = NA_character_, date_infection)
  dates <- sort(dates, na.last = TRUE)
  w <- simulacr::make_pmf_delay(w)
  stopifnot(
    inherits(dates, "Date"),
    length(dates) > 0,
    all(is.finite(dates)),
    all(diff(dates) == 1),
    inherits(imported$date_infection, "Date"),
    all(is.finite(imported$date_infection)),
    !anyDuplicated(imported$id),
    all(imported$id %in% population$id),
    !anyNA(population$id)
  )

  # Imports are scheduled cases; infections records cases that have occurred.
  infections <- filter(imported, date_infection < dates[1])
  ids <- unique(population$id)
  cumulative_foi <- stats::setNames(numeric(length(ids)), ids)

  for (i in seq_along(dates)) {
    date <- dates[i]
    infections <- bind_rows(
      infections,
      filter(imported, date_infection == .env$date, !id %in% .env$infections$id)
    )
    present <- population |>
      filter(start <= .env$date, end >= .env$date) |>
      arrange(id) |>
      left_join(infections, by = "id") |>
      mutate(infection_age = as.integer(.env$date - date_infection))
    stopifnot(!anyDuplicated(present$id))

    # simulacr uses integer dates and -1 for people not yet infected.
    t <- as.integer(date)
    S <- is.na(present$date_infection)
    date_infection <- dplyr::if_else(S, -1L, as.integer(present$date_infection))
    rates <- tau(present, date)
    stopifnot(
      is.numeric(rates), length(rates) == nrow(present),
      all(is.finite(rates) & rates >= 0)
    )
    present <- present |>
      mutate(
        tau = .env$rates,
        infectiousness = as.numeric(!.env$S) * tau *
          .env$w(.env$t - .env$date_infection)
      )

    C_effective <- align_pairwise(contacts(present, date), present$id)
    diag(C_effective) <- 0
    if (!is.null(intervention)) {
      E_t <- align_pairwise(intervention(present, date), present$id, upper = 1)
      C_effective <- C_effective * (1 - E_t)
    }
    cumulative_foi[present$id] <- cumulative_foi[present$id] +
      present$infectiousness * rowSums(C_effective)

    step <- simulacr::simulate_outbreak_step(
      t = t, labels = present$id, S = S, I = !S,
      date_infection = date_infection, C = C_effective, tau = rates, w = w
    )
    new <- tibble::as_tibble(step$tree) |>
      transmute(
        id = .data$to, source = .data$from,
        date_infection = as.Date(.data$date, origin = "1970-01-01")
      )
    infections <- bind_rows(infections, new)
  }

  structure(
    list(
      population = population,
      infections = arrange(infections, date_infection, id),
      reproduction = tibble(
        id = names(cumulative_foi), R_i = unname(cumulative_foi)
      ),
      dates = dates,
      parameters = list(
        imported = select(imported, id, date_infection),
        w = w,
        contacts = contacts,
        tau = tau,
        intervention = intervention
      )
    ),
    class = "nososim_outbreak"
  )
}

population_tau <- function(present, date) {
  present$tau
}

# Align callback matrices once, checking only values and ID coverage.
align_pairwise <- function(x, ids, upper = Inf) {
  stopifnot(
    is.matrix(x),
    is.numeric(x),
    identical(dim(x), c(length(ids), length(ids))),
    setequal(rownames(x), ids),
    setequal(colnames(x), ids),
    all(is.finite(x) & x >= 0 & x <= upper)
  )
  x[ids, ids, drop = FALSE]
}

#' @export
#' @noRd
print.nososim_outbreak <- function(x, ...) {
  cat("<nososim_outbreak>\n")
  print(unclass(x), ...)
  invisible(x)
}
