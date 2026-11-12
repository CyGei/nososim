# Expand attribute weights to person pairs in population order.
mixing_matrix <- function(present, mixing = NULL) {
  if (length(mixing)) {
    stopifnot(
      is.list(mixing),
      rlang::is_named(mixing),
      !anyDuplicated(names(mixing)),
      all(names(mixing) %in% names(present))
    )
  }

  result <- matrix(
    1, nrow(present), nrow(present),
    dimnames = list(present$id, present$id)
  )
  for (attribute in names(mixing)) {
    weights <- mixing[[attribute]]
    values <- as.character(present[[attribute]])
    stopifnot(
      is.matrix(weights),
      is.numeric(weights),
      all(is.finite(weights) & weights >= 0),
      !anyDuplicated(rownames(weights)),
      !anyDuplicated(colnames(weights)),
      !anyNA(values)
    )
    result <- result * weights[values, values, drop = FALSE]
  }
  result
}
