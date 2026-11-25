#' Expand attribute multipliers to individual pairs
#'
#' Shared by [get_contacts()] and [get_intervention()].
#' @param data Table with validated unique `labels` and attribute columns.
#' @param multipliers Named list of finite, non-negative numeric matrices, one
#'   per attribute. Rows name source categories; columns name recipient
#'   categories. Both axes must cover all observed values.
#' @return A numeric matrix in `data` row order, named by `labels` on both axes.
#'   Entries are products across attributes, without normalisation. `NULL` or
#'   an empty list returns all ones. No location rules or diagonal removal
#'   are applied.
#' @noRd
mixing_matrix <- function(data, multipliers) {
  if (is.null(multipliers)) {
    multipliers <- list()
  }
  stopifnot(
    "`multipliers` must be a list named by population attributes." =
      is.list(multipliers) && (!length(multipliers) || rlang::is_named(multipliers)) &&
      !anyDuplicated(names(multipliers)) && all(names(multipliers) %in% names(data))
  )

  result <- matrix(
    1, nrow(data), nrow(data),
    dimnames = list(data$labels, data$labels)
  )
  for (attribute in names(multipliers)) {
    m <- multipliers[[attribute]]
    values <- as.character(data[[attribute]])
    check_matrix(m, values)
    result <- result * m[values, values, drop = FALSE]
  }
  result
}
