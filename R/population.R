#' Create a population
#'
#' Draws admissions from available capacity, then generates only the
#' admitted records. Each stay starts today and includes `end`; capacity is free the next day.
#'
#' @param landscape A table from [make_landscape()], with a `capacity` column per location.
#' @param dates Consecutive daily dates.
#' @param admissions Function `(landscape, date)` returning one non-negative
#'   integer admission count per location, in row order, no greater than
#'   its available capacity.
#' @param individuals Function `(admitted, date)` returning one record per admitted
#'   person, in the same order. Preserve location columns and supply `start`
#'   (the current date) and `end` (the last day present, on or after `start`). All other columns are yours.
#' @details Each day, `make_population()` calls your functions with the tables and
#'   date they need. It passes a daily copy of `landscape` to `admissions()`,
#'   with an `available` column giving today's free capacity; `capacity` remains
#'   the total capacity. Admission counts exceeding availability are errors.
#'   The `available` column is calculated each day, replacing any input column
#'   with that name. It then creates `admitted`, with one row per admitted person, and passes
#'   it to `individuals()`. It contains the
#'   landscape columns except `capacity`. Keep both arguments in your function definitions,
#'   even if your rule does not use the date.
#'   In the example, `filling_rate` is a per-available-bed daily rate,
#'   converted to a filling probability with `1 - exp(-filling_rate)`.
#' @return A population tibble of admitted records, with location and date
#'   metadata for [autoplot()].
#' @export
#' @examples
#' landscape <- dplyr::mutate(make_landscape(c(A = 1, B = 2)), filling_rate = 0.5)
#' make_population(
#'   landscape, as.Date("2026-01-01") + 0:4,
#'   admissions = function(landscape, date) {
#'     stats::rbinom(nrow(landscape), size = landscape$available,
#'       prob = 1 - exp(-landscape$filling_rate))
#'   },
#'   individuals = function(admitted, date) {
#'     dplyr::mutate(admitted, start = date, end = date + 2L)
#'   }
#' )
make_population <- function(landscape, dates, admissions, individuals) {
  landscape <- tibble::as_tibble(landscape)
  dates <- sort(dates, na.last = TRUE)
  stopifnot(
    inherits(dates, "Date"),
    length(dates) > 0,
    all(is.finite(dates)),
    all(diff(dates) == 1)
  )

  # Track each admitted person's location and departure date.
  where <- integer()
  ends <- dates[0]
  records <- list()

  for (i in seq_along(dates)) {
    date <- dates[i]

    # Count people still present and find free capacity.
    occupied <- tabulate(where[ends >= date], nrow(landscape))
    available <- landscape$capacity - occupied

    daily_landscape <- dplyr::mutate(landscape, available = .env$available)
    counts <- admissions(daily_landscape, date)
    check_counts(counts, nrow(landscape), available)
    if (sum(counts) == 0) {
      next
    }

    # Generate records only for admitted people.
    admitted <- landscape |>
      mutate(capacity = .env$counts) |>
      tidyr::uncount(capacity)
    population <- individuals(admitted, date)
    check_individuals(population, admitted, date)

    # Keep the records and track occupancy for subsequent days.
    where <- c(where, rep(seq_len(nrow(landscape)), counts))
    ends <- c(ends, population$end)
    records[[length(records) + 1L]] <- population
  }

  population <- bind_rows(records)
  tibble::new_tibble(
    as.list(population),
    nrow = nrow(population),
    landscape = landscape,
    dates = dates,
    class = "nososim_population"
  )
}

check_individuals <- function(population, admitted, date) {
  keys <- level_columns(admitted)
  stopifnot(
    identical(as.list(population[keys]), as.list(admitted[keys])),
    inherits(population$start, "Date"),
    inherits(population$end, "Date"),
    all(population$start == date),
    all(is.finite(population$end) & population$end >= date)
  )
}
