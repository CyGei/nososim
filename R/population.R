#' Create a population
#'
#' Draws arrival counts, limits them to available capacity, then generates only the
#' admitted records. Each stay starts today and includes `end`; capacity is free the next day.
#'
#' @param landscape A table from [make_landscape()], with capacity `n` per location.
#' @param dates Consecutive daily dates.
#' @param admissions Function `(landscape, date)` returning one non-negative
#'   integer attempted arrival count per location, in row order.
#' @param individuals Function `(admitted, date)` returning one record per admitted
#'   person, in the same order. Preserve location columns and supply `start`
#'   (the current date) and `end` (the last day present, on or after `start`). All other columns are yours.
#' @details Each day, `make_population()` calls your functions with the tables and
#'   date they need. It passes `landscape` to `admissions()`. After checking free
#'   capacity, it creates `admitted`, with one row per admitted person, and passes
#'   it to `individuals()`. It contains the
#'   landscape columns except `n`. Keep both arguments in your function definitions,
#'   even if your rule does not use the date.
#' @return A population tibble of admitted records, with location and date
#'   metadata for [autoplot()].
#' @export
#' @examples
#' landscape <- make_landscape(c(A = 1, B = 2))
#' make_population(
#'   landscape, as.Date("2026-01-01") + 0:4,
#'   admissions = function(landscape, date) rep(1L, nrow(landscape)),
#'   individuals = function(admitted, date) {
#'     dplyr::mutate(admitted, start = date, end = date + 2L)
#'   }
#' )
make_population <- function(landscape, dates, admissions, individuals) {
  landscape <- tibble::as_tibble(landscape)
  keys <- grep("^location_[0-9]+$", names(landscape), value = TRUE)
  stopifnot(
    length(keys) > 0,
    !anyDuplicated(landscape[keys]),
    is.numeric(landscape$n),
    is.null(dim(landscape$n)),
    all(is.finite(landscape$n)),
    all(landscape$n >= 0 & landscape$n == floor(landscape$n))
  )

  stopifnot(
    inherits(dates, "Date"),
    length(dates) > 0,
    all(is.finite(dates)),
    all(diff(sort(dates)) == 1)
  )
  dates <- sort(dates)

  # Track each admitted person's location and departure date.
  where <- integer()
  ends <- dates[0]
  records <- list()

  for (i in seq_along(dates)) {
    date <- dates[i]

    # Count people still present and find free capacity.
    occupied <- tabulate(where[ends >= date], nrow(landscape))
    available <- landscape$n - occupied

    # Limit arrivals to available capacity.
    arrivals <- admissions(landscape, date)
    stopifnot(
      is.numeric(arrivals),
      is.null(dim(arrivals)),
      length(arrivals) == nrow(landscape),
      all(is.finite(arrivals)),
      all(arrivals >= 0 & arrivals == floor(arrivals))
    )
    counts <- pmin(available, arrivals)
    if (sum(counts) == 0) {
      next
    }

    # Generate records only for admitted people.
    admitted <- landscape |>
      mutate(n = .env$counts) |>
      tidyr::uncount(n)
    population <- individuals(admitted, date)
    stopifnot(
      is.data.frame(population),
      identical(as.list(population[keys]), as.list(admitted[keys])),
      inherits(population$start, "Date"),
      inherits(population$end, "Date"),
      is.null(dim(population$start)),
      is.null(dim(population$end)),
      all(population$start == date),
      all(is.finite(population$end)),
      all(population$end >= date)
    )

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
