
#' Generate a daily population timeline
#'
#' Creates a population with individual reproduction numbers, admission
#' dates, lengths of stay, and optional attributes. Individuals are
#' present from admission up to, but excluding, discharge.
#'
#' @param n Number of individuals.
#' @param dates Vector of unique dates.
#' @param attributes Named list of attribute values and their sampling weights.
#' @param admission_delay Possible admission delays (days from the first date).
#' @param stay Possible lengths of stay (days).
#' @param R Possible individual reproduction numbers.
#'
#' @return A `nososim_timeline` tibble with one row per person-day,
#'   containing `id`, `date`, `R_i`, and optional attributes.
#'
#' @export
#' @examples
#' dates <- as.Date("2026-01-01") + 0:6
#' make_timeline(2, dates, stay = 3)

make_timeline <- function(
  n,
  dates,
  attributes = list(),
  admission_delay = 0,
  stay = 7:14,
  R = 2
) {
  stopifnot(
    n > 0,
    inherits(dates, "Date"),
    length(dates) > 0,
    !anyNA(dates),
    !anyDuplicated(dates)
  )

  individuals <- tibble(
    id = paste0("ID_", seq_len(n)),
    R_i = draw(R, n),
    admission = min(dates) + draw(admission_delay, n),
    stay = draw(stay, n)
  )

  for (name in names(attributes)) {
    individuals[[name]] <- sample(
      names(attributes[[name]]),
      n,
      replace = TRUE,
      prob = attributes[[name]]
    )
  }

  individuals |>
    mutate(discharge = admission + stay) |>
    tidyr::expand_grid(date = dates) |>
    filter(date >= admission, date < discharge) |>
    select(id, date, R_i, all_of(names(attributes))) |>
    arrange(id, date) |>
    new_timeline()
}


#' Update individual attributes
#'
#' Assigns attribute values to selected individuals over a date interval.
#'
#' @param timeline A population timeline.
#' @param id Individual ID(s) to update.
#' @param from Start date (inclusive).
#' @param to End date (exclusive), or `NULL` for all subsequent dates.
#' @param attributes Named list of existing attributes and their new values.
#'
#' @return The updated timeline.
#'
#' @export
#' @examples
#' dates <- as.Date("2026-01-01") + 0:6
#' timeline <- make_timeline(2, dates, attributes = list(ward = c(A = 1)))
#' set_attribute(timeline, "ID_1", dates[3], attributes = list(ward = "B"))

set_attribute <- function(timeline, id, from, to = NULL, attributes) {
  stopifnot(
    all(names(attributes) %in% names(timeline)),
    all(lengths(attributes) == 1)
  )

  rows <- timeline$id %in% id & timeline$date >= from
  if (!is.null(to)) {
    rows <- rows & timeline$date < to
  }

  for (name in names(attributes)) {
    timeline[[name]][rows] <- attributes[[name]]
  }
  timeline
}


#' Set individual weekly schedules
#'
#' Removes days outside the specified weekdays for selected individuals.
#'
#' @param timeline A population timeline.
#' @param id Individual ID(s) to update.
#' @param weekdays Weekdays to retain (Monday = 1, Sunday = 7).
#'
#' @return The timeline with off-days removed for selected individuals.
#'
#' @export
#' @examples
#' dates <- as.Date("2026-01-01") + 0:6
#' timeline <- make_timeline(2, dates)
#' set_schedule(timeline, "ID_1", weekdays = 1:5)
set_schedule <- function(timeline, id, weekdays = 1:5) {
  timeline |>
    filter(
      !.data$id %in% .env$id |
        as.integer(format(date, "%u")) %in% {{ weekdays }}
    )
}


#' Sample values uniformly with replacement
#'
#' @param x Vector of possible values.
#' @param n Number of draws.
#'
#' @return A vector of `n` sampled values.
#' @noRd
draw <- function(x, n) {
  x[sample.int(length(x), n, replace = TRUE)]
}

#' @noRd
new_timeline <- function(data) {
  tibble::new_tibble(as.list(data), nrow = nrow(data), class = "nososim_timeline")
}
