#' Find daily contacts
#'
#' Two people are in contact when all their `by` values match.
#'
#' @param population A table with unique `id`, `start`, `end`, and grouping columns.
#' @param date A single Date. Both `start` and `end` are included.
#' @param by Columns to match, including any location or attribute columns.
#'   Defaults to all `location_*` columns. Missing values match missing values.
#' @return A symmetric matrix of 0s and 1s, named by the IDs present on `date`,
#'   in population row order. The diagonal is zero. No people present gives a
#'   0-by-0 matrix.
#' @export
#' @examples
#' population <- tibble::tibble(
#'   id = c("a", "b", "c"),
#'   location_1 = c("A", "A", "B"),
#'   role = c("patient", "staff", "patient"),
#'   start = as.Date("2026-01-01"),
#'   end = as.Date("2026-01-03")
#' )
#' get_contacts(population, as.Date("2026-01-02"))
#' get_contacts(population, as.Date("2026-01-02"),
#'   by = c("location_1", "role"))
get_contacts <- function(
  population,
  date,
  by = grep("^location_[0-9]+$", names(population), value = TRUE)
) {
  stopifnot(
    inherits(date, "Date"),
    length(date) == 1,
    !is.na(date),
    length(by) > 0,
    all(c("id", "start", "end", by) %in% names(population))
  )

  # Keep people present on this date.
  present <- tibble::as_tibble(population) |>
    filter(start <= .env$date, end >= .env$date)
  stopifnot(!anyNA(present$id), !anyDuplicated(present$id))

  # People with matching values belong to the same group.
  groups <- present |>
    dplyr::group_by(dplyr::across(all_of(by))) |>
    dplyr::group_indices()

  contacts <- 1L * outer(groups, groups, "==")
  diag(contacts) <- 0L
  dimnames(contacts) <- list(present$id, present$id)
  contacts
}
