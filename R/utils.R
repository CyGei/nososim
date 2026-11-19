level_columns <- function(data) {
  grep("^level_[0-9]+$", names(data), value = TRUE)
}

check_counts <- function(counts, size = length(counts), available = Inf) {
  stopifnot(
    "Counts must be whole numbers, one per location, within available capacity." =
      is.numeric(counts) && length(counts) == size &&
      all(is.finite(counts) & counts >= 0 & counts == floor(counts) & counts <= available)
  )
}

check_labels <- function(labels) {
  stopifnot(
    "Labels must be unique, non-missing and non-empty." =
      !is.null(labels) && !anyNA(labels) &&
      all(nzchar(labels)) && !anyDuplicated(labels)
  )
}

check_attributes <- function(data) {
  stopifnot(
    "`stay` must contain positive whole days or Inf." =
      is.numeric(data$stay) && all(data$stay >= 1 & data$stay == floor(data$stay)),
    "`tau` must contain finite, non-negative rates." =
      is.numeric(data$tau) && all(is.finite(data$tau) & data$tau >= 0)
  )
}

check_matrix <- function(x, labels) {
  stopifnot(
    "Contacts and multipliers must be finite, non-negative numeric matrices." =
      is.matrix(x) && is.numeric(x) && all(is.finite(x) & x >= 0),
    "Matrix names must be unique and cover every supplied label or category." =
      !anyNA(labels) && !anyDuplicated(rownames(x)) &&
      !anyDuplicated(colnames(x)) &&
      all(labels %in% rownames(x)) && all(labels %in% colnames(x))
  )
}
