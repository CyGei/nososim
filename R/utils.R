level_columns <- function(data) {
  grep("^level_[0-9]+$", names(data), value = TRUE)
}

check_counts <- function(counts, size = length(counts), available = Inf) {
  stopifnot(
    is.numeric(counts),
    length(counts) == size,
    all(
      is.finite(counts) & counts >= 0 & counts == floor(counts) &
        counts <= available
    )
  )
}
