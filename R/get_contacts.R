#' Build a contact matrix
#'
#' Match individuals by location or a pairwise rule, then apply optional weights.
#'
#' @param data Current occupants, with unique `labels` and grouping columns.
#' @param by Columns to match (default: all `level_*` columns), or a vectorised
#'   function `(i, j)` comparing corresponding rows of two tables. Column matching
#'   treats missing values as equal. Functions must return symmetric logical
#'   results; `NA` means no contact. Self-pairs are excluded; functions are skipped
#'   with fewer than two occupants.
#' @param weights Optional named list of numeric matrices, one per attribute.
#'   Rows name source categories; columns name recipient categories. Names must
#'   be unique and cover all observed categories on both axes. Values must be
#'   finite and non-negative; missing attributes are errors. Weights multiply
#'   across attributes without normalisation. `NULL` or an empty list means no
#'   weighting. Excluded contacts remain zero.
#' @return A matrix in `data` row order, with source labels in rows, recipient
#'   labels in columns, and a zero diagonal. Unweighted contacts are symmetric
#'   0s and 1s; weighted intensities may be asymmetric. Empty input returns a
#'   0-by-0 matrix.
#' @export
#' @examples
#' data <- tibble::tibble(
#'   labels = c("a", "b", "c"),
#'   level_1 = c("A", "A", "B"),
#'   role = c("patient", "staff", "patient")
#' )
#' get_contacts(data)
#' get_contacts(data, by = c("level_1", "role"))
#' get_contacts(data, by = function(i, j) i$level_1 == j$level_1)
#' role_weights <- matrix(c(1, 2, 1, 1), 2, byrow = TRUE,
#'   dimnames = list(c("patient", "staff"), c("patient", "staff")))
#' get_contacts(data, by = "level_1",
#'   weights = list(role = role_weights))
get_contacts <- function(
  data,
  by = level_columns(data),
  weights = NULL
) {
  stopifnot(
    "labels" %in% names(data),
    !anyNA(data$labels),
    !anyDuplicated(data$labels),
    is.function(by) || (is.character(by) && length(by) > 0)
  )
  data <- tibble::as_tibble(data)

  if (is.function(by)) {
    contacts <- pairwise_contacts(data, by)
  } else {
    # People with matching values belong to the same group.
    groups <- data |>
      dplyr::group_by(dplyr::across(all_of(by))) |>
      dplyr::group_indices()

    contacts <- 1L * outer(groups, groups, "==")
  }
  diag(contacts) <- 0L
  dimnames(contacts) <- list(data$labels, data$labels)
  if (length(weights)) {
    contacts <- contacts * mixing_matrix(data, weights)
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
