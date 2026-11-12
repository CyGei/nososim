#' Find daily contacts
#'
#' Define contacts using matching columns or a pairwise function, then optionally
#' multiply them by attribute-specific weights without normalisation.
#'
#' @param population A table with unique `id`, `start`, `end`, and grouping columns.
#' @param date A single Date. Both `start` and `end` are included.
#' @param by A character vector of columns to match, or a vectorised function
#'   `(i, j)` returning one logical value per pair. `i` and `j` are tables whose
#'   corresponding rows are the people being compared. Defaults to all
#'   `level_*` columns. For column matching, missing values match missing values.
#'   For functions, `NA` results mean no contact, and results must be symmetric.
#'   Self-pairs are excluded; the function is not called with fewer than two
#'   people present.
#' @param weights Optional named list of numeric matrices. List names identify
#'   population columns; matrix row names identify source categories and column
#'   names identify recipient categories. Coefficients must be finite and
#'   non-negative, with unique category names covering everyone present on both
#'   axes. Missing values in weighted attributes are errors. Coefficients multiply
#'   across attributes. `NULL` or an empty list leaves contacts unweighted.
#' @return A matrix named by the IDs present on `date`, in population row order.
#'   Without weights, entries are symmetric 0s and 1s. With weights, entries are
#'   non-negative contact intensities and may be asymmetric. Rows are sources
#'   and columns recipients. The diagonal is zero; no people present gives a
#'   0-by-0 matrix.
#' @export
#' @examples
#' population <- tibble::tibble(
#'   id = c("a", "b", "c"),
#'   level_1 = c("A", "A", "B"),
#'   role = c("patient", "staff", "patient"),
#'   start = as.Date("2026-01-01"),
#'   end = as.Date("2026-01-03")
#' )
#' get_contacts(population, as.Date("2026-01-02"))
#' get_contacts(population, as.Date("2026-01-02"),
#'   by = c("level_1", "role"))
#' get_contacts(population, as.Date("2026-01-02"),
#'   by = function(i, j) i$level_1 == j$level_1)
#' role_weights <- matrix(c(1, 2, 1, 1), 2, byrow = TRUE,
#'   dimnames = list(c("patient", "staff"), c("patient", "staff")))
#' get_contacts(population, as.Date("2026-01-02"), by = "level_1",
#'   weights = list(role = role_weights))
get_contacts <- function(
  population,
  date,
  by = level_columns(population),
  weights = NULL
) {
  stopifnot(
    inherits(date, "Date"),
    length(date) == 1,
    is.finite(date),
    "id" %in% names(population),
    is.function(by) || (is.character(by) && length(by) > 0)
  )

  present <- tibble::as_tibble(population) |>
    filter(start <= .env$date, end >= .env$date)
  stopifnot(!anyNA(present$id), !anyDuplicated(present$id))

  if (is.function(by)) {
    contacts <- pairwise_contacts(present, by)
  } else {
    # People with matching values belong to the same group.
    groups <- present |>
      dplyr::group_by(dplyr::across(all_of(by))) |>
      dplyr::group_indices()

    contacts <- 1L * outer(groups, groups, "==")
  }
  diag(contacts) <- 0L
  dimnames(contacts) <- list(present$id, present$id)
  if (length(weights)) {
    contacts <- contacts * mixing_matrix(present, weights)
  }
  contacts
}

pairwise_contacts <- function(present, by) {
  n <- nrow(present)
  contacts <- matrix(0L, n, n)
  if (n < 2L) {
    return(contacts)
  }

  # Compare both directions, leaving out self-pairs.
  pairs <- which(row(contacts) != col(contacts), arr.ind = TRUE)
  matches <- by(present[pairs[, 1], ], present[pairs[, 2], ])
  stopifnot(is.logical(matches), length(matches) == nrow(pairs))
  contacts[pairs] <- as.integer(!is.na(matches) & matches)
  stopifnot(isSymmetric(contacts))
  contacts
}
