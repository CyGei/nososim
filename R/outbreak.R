#' Simulate an outbreak
#'
#' Each day: admit individuals, introduce infections, build contacts, apply
#' interventions, simulate transmission, update attributes, then process departures.
#'
#' @param population A [make_population()] model or named list of models with
#'   separate capacities. Labels must identify people across all models.
#' @param dates Consecutive daily Dates.
#' @param w Generation-time PMF accepted by [simulacr::make_pmf_delay()]. Numeric
#'   weights are normalised and correspond to delays 0, 1, 2, etc.
#' @param imported Function `(data, t)` returning character labels of susceptible
#'   occupants to infect on date `t`. Return `character()` for none.
#' @param contacts Function `(data, t)` returning a finite, non-negative matrix:
#'   source labels in rows, recipient labels in columns. Use
#'   `function(data, t) get_contacts(data)` to match all location levels.
#'   Optionally use [sample_contacts()] to draw daily counts. Return a zero
#'   matrix for no contacts. Self-contact is set to zero.
#' @param intervention Optional function `(data, t)` returning a transmission
#'   multiplier matrix `E`, named by person labels (rows: sources; columns:
#'   recipients). `NULL` leaves transmission unchanged.
#'   Values must be finite and non-negative (0: blocked, 1: unchanged,
#'   `>1`: increased transmission). See [get_intervention()].
#' @details `t` is a Date. `imported()` receives only susceptible occupants;
#'   `contacts()` and `intervention()` receive everyone present, after imports.
#'   Callbacks are skipped when their input is empty. Both matrices must have
#'   exactly one row and column per occupant; names are aligned automatically.
#'
#'   Transmission uses `C * E` element by element, with `E = 1` when no
#'   intervention is supplied. This scales the source's `tau` and generation-time
#'   weight without normalising contacts. [simulacr::simulate_outbreak_step()]
#'   records infections on `t`; new local cases cannot transmit in the same step.
#'
#'   Updates run after transmission and before departures. They affect the next
#'   day's transmission, but can extend a stay before today's departure. Vacated
#'   places become available the following day.
#'
#' @return A `nososim_outbreak` list with:
#'   * `population`: a tibble of daily snapshots after imports, before local infections and
#'     updates, including `labels`, `t`, and `population`.
#'   * `infections`: `from`, `to`, and `date`; imported cases have `from = NA`.
#'   * `landscape`: location capacities for each population.
#'   * `dates` and `parameters`: simulation settings.
#' @export
#' @examples
#' population <- make_population(
#'   make_landscape(list(A = 10)),
#'   arrivals = function(data, t) data$available,
#'   attributes = function(data, t) dplyr::mutate(data, stay = 5L, tau = 0.1)
#' )
#' dates <- as.Date("2026-01-01") + 0:6
#' make_outbreak(population, dates, w = c(0, 0.5, 0.5),
#'   imported = function(data, t) {
#'     if (t == dates[1]) head(data$labels, 1) else character()
#'   },
#'   contacts = function(data, t) get_contacts(data)
#' )
make_outbreak <- function(
  population,
  dates,
  w,
  imported,
  contacts,
  intervention = NULL
) {
  models <- if (inherits(population, "nososim_population")) {
    list(population = population)
  } else {
    population
  }
  dates <- sort(dates, na.last = TRUE)
  stopifnot(
    is.list(models),
    length(models) > 0,
    rlang::is_named(models),
    !anyDuplicated(names(models)),
    purrr::every(models, inherits, "nososim_population"),
    inherits(dates, "Date"),
    length(dates) > 0,
    all(is.finite(dates)),
    all(diff(dates) == 1),
    is.function(imported),
    is.function(contacts),
    is.null(intervention) || is.function(intervention)
  )
  if (is.numeric(w)) {
    stopifnot("`w` must have a positive total weight." = sum(w) > 0)
  }
  w <- simulacr::make_pmf_delay(w)

  landscape <- models |>
    purrr::map("landscape") |>
    bind_rows(.id = "population")
  # One table of current occupants; infection history survives their departures.
  current <- landscape[0, level_columns(landscape)] |>
    mutate(
      labels = character(),
      start = dates[0],
      stay = double(),
      tau = double(),
      date_infection = dates[0],
      population = character(),
      .location = integer()
    )
  infections <- tibble(from = character(), to = character(), date = dates[0])
  known_labels <- character()
  history <- vector("list", length(dates))

  for (day in seq_along(dates)) {
    t <- dates[day]

    # Admit into each group's free places, restoring returning people's history.
    for (group in names(models)) {
      entrants <- current |>
        filter(population == .env$group) |>
        admit_individuals(
          model = models[[group]],
          current = _,
          t = t,
          known_labels = known_labels
        )
      if (!nrow(entrants)) {
        next
      }
      entrants <- entrants |>
        mutate(population = .env$group) |>
        left_join(
          infections |> select(labels = to, date_infection = date),
          by = "labels"
        )
      known_labels <- union(known_labels, entrants$labels)
      current <- bind_rows(current, entrants)
    }
    # Keep model order, then existing residents before entrants within each model.
    current <- current |>
      arrange(match(population, names(.env$models)))
    check_labels(current$labels)

    # Introduce infections before building today's contacts.
    susceptible <- current |>
      filter(is.na(date_infection)) |>
      select(-.location)

    if (nrow(susceptible)) {
      introductions <- imported(susceptible, t)
      stopifnot(
        "`imported()` must return unique labels of susceptible occupants." = is.character(
          introductions
        ) &&
          !anyDuplicated(introductions) &&
          all(introductions %in% susceptible$labels)
      )
      current <- current |>
        mutate(
          date_infection = dplyr::if_else(
            labels %in% .env$introductions,
            .env$t,
            date_infection
          )
        )
      infections <- bind_rows(
        infections,
        tibble(from = NA_character_, to = introductions, date = t)
      )
    }
    # Save the attributes used for transmission, before local cases and updates.
    daily_population <- select(current, -.location)
    history[[day]] <- mutate(daily_population, t = .env$t)
    if (nrow(daily_population)) {
      C <- contacts(daily_population, t) |>
        align_pairwise(daily_population$labels)
      diag(C) <- 0
    } else {
      C <- matrix(numeric(), 0, 0)
    }
    C_effective <- C
    if (nrow(daily_population) && !is.null(intervention)) {
      E <- intervention(daily_population, t) |>
        align_pairwise(daily_population$labels)
      C_effective <- C * E
    }
    S <- is.na(daily_population$date_infection)
    step <- simulacr::simulate_outbreak_step(
      t = as.integer(t),
      labels = daily_population$labels,
      S = S,
      I = !S,
      date_infection = dplyr::coalesce(
        as.integer(daily_population$date_infection),
        -1L
      ),
      C = C_effective,
      tau = daily_population$tau,
      w = w
    )
    new_infections <- step$tree |>
      tibble::as_tibble() |>
      mutate(date = as.Date(date, origin = "1970-01-01"))
    infections <- bind_rows(infections, new_infections)

    # Today's infections can change attributes and extend a stay before discharge.
    current <- current |>
      mutate(
        date_infection = as.Date(
          dplyr::if_else(.env$step$S, NA_integer_, .env$step$date_infection),
          origin = "1970-01-01"
        )
      ) |>
      update_population(models, t) |>
      filter(as.integer(.env$t - start) + 1L < stay)
  }

  structure(
    list(
      population = bind_rows(history),
      landscape = landscape,
      infections = arrange(infections, date, to),
      dates = dates,
      parameters = list(
        population = models,
        w = w,
        imported = imported,
        contacts = contacts,
        intervention = intervention
      )
    ),
    class = "nososim_outbreak"
  )
}

# Align the matrix with the supplied labels, preserving directed intensities.
align_pairwise <- function(x, labels) {
  check_matrix(x, labels)
  stopifnot(
    "Pairwise matrices must have one row and column per occupant." = identical(
      dim(x),
      rep(length(labels), 2)
    )
  )
  x[labels, labels, drop = FALSE]
}

#' @export
#' @noRd
print.nososim_outbreak <- function(x, ...) {
  cat("<nososim_outbreak>\n")
  cat(format(min(x$dates)), "to", format(max(x$dates)), "\n")
  cat(
    length(unique(x$population$labels)),
    "individuals;",
    sum(is.na(x$infections$from)),
    "imported cases;",
    sum(!is.na(x$infections$from)),
    "local cases\n"
  )
  invisible(x)
}
