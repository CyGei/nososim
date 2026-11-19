# Expand attribute multipliers to person pairs in population order.
mixing_matrix <- function(present, mixing) {
  stopifnot(
    "`multipliers` must be a list named by population attributes." =
      is.list(mixing) && rlang::is_named(mixing) &&
      !anyDuplicated(names(mixing)) && all(names(mixing) %in% names(present))
  )

  result <- matrix(
    1, nrow(present), nrow(present),
    dimnames = list(present$labels, present$labels)
  )
  for (attribute in names(mixing)) {
    multipliers <- mixing[[attribute]]
    values <- as.character(present[[attribute]])
    check_matrix(multipliers, values)
    result <- result * multipliers[values, values, drop = FALSE]
  }
  result
}
