#' Populate available places
#'
#' Draws arrival counts, limits them to free places, then generates only the
#' admitted records. Each stay starts today and frees its place at `end`.
#'
#' @param locations A table from [make_landscape()], with `n` places per location.
#' @param dates Consecutive daily dates.
#' @param admissions Function `(locations, date)` returning one non-negative
#'   integer attempted arrival count per location, in row order.
#' @param individuals Function `(places, date)` returning one record per allocated
#'   place, in the same order. Preserve location columns and supply `start`
#'   (the current date) and `end` (a later date). All other columns are yours.
#' @return A population tibble of admitted records, with location and date
#'   metadata for [autoplot()].
#' @export
#' @examples
#' locations <- make_landscape(c(A = 1, B = 2))
#' make_population(
#'   locations, as.Date("2026-01-01") + 0:4,
#'   admissions = function(locations, date) rep(1L, nrow(locations)),
#'   individuals = function(places, date) {
#'     dplyr::mutate(places, start = date, end = date + 2L)
#'   }
#' )
make_population <- function(locations, dates, admissions, individuals) {
  locations <- tibble::as_tibble(locations)
  keys <- grep("^location_[0-9]+$", names(locations), value = TRUE)
  stopifnot(
    length(keys) > 0,
    !anyDuplicated(locations[keys]),
    is.numeric(locations$n),
    is.null(dim(locations$n)),
    all(is.finite(locations$n)),
    all(locations$n >= 0 & locations$n == floor(locations$n))
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

    # Count people still present and find free places.
    occupied <- tabulate(where[ends > date], nrow(locations))
    available <- locations$n - occupied

    # Limit arrivals to the available places.
    arrivals <- admissions(locations, date)
    stopifnot(
      is.numeric(arrivals),
      is.null(dim(arrivals)),
      length(arrivals) == nrow(locations),
      all(is.finite(arrivals)),
      all(arrivals >= 0 & arrivals == floor(arrivals))
    )
    admitted <- pmin(available, arrivals)
    if (sum(admitted) == 0) {
      next
    }

    # Generate records only for admitted people.
    places <- locations |>
      mutate(n = .env$admitted) |>
      tidyr::uncount(n)
    people <- individuals(places, date)
    stopifnot(
      is.data.frame(people),
      identical(as.list(people[keys]), as.list(places[keys])),
      inherits(people$start, "Date"),
      inherits(people$end, "Date"),
      is.null(dim(people$start)),
      is.null(dim(people$end)),
      all(people$start == date),
      all(is.finite(people$end)),
      all(people$end > date)
    )

    # Keep the records and track occupancy for subsequent days.
    where <- c(where, rep(seq_len(nrow(locations)), admitted))
    ends <- c(ends, people$end)
    records[[length(records) + 1L]] <- people
  }

  population <- bind_rows(records)
  tibble::new_tibble(
    as.list(population),
    nrow = nrow(population),
    locations = locations,
    dates = dates,
    class = "nososim_population"
  )
}
