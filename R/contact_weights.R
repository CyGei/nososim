# Apply weights to the daily population already aligned by get_contacts().
apply_contact_weights <- function(contacts, present, weights) {
  if (
    !is.list(weights) ||
      (length(weights) > 0L &&
        (!rlang::is_named(weights) || anyDuplicated(names(weights))))
  ) {
    stop("`weights` must be a list with unique attribute names.", call. = FALSE)
  }
  if (!all(names(weights) %in% names(present))) {
    stop(
      "Every name in `weights` must identify a population column.",
      call. = FALSE
    )
  }

  purrr::reduce(
    names(weights),
    function(result, attribute) {
      coefficients <- weights[[attribute]]
      if (
        !is.matrix(coefficients) ||
          !is.numeric(coefficients) ||
          any(!is.finite(coefficients)) ||
          any(coefficients < 0)
      ) {
        stop(
          sprintf(
            "Weights for `%s` must be a matrix of finite, non-negative numbers.",
            attribute
          ),
          call. = FALSE
        )
      }
      labels <- dimnames(coefficients)
      if (
        is.null(labels[[1]]) ||
          is.null(labels[[2]]) ||
          anyNA(labels[[1]]) ||
          anyNA(labels[[2]]) ||
          any(!nzchar(labels[[1]])) ||
          any(!nzchar(labels[[2]])) ||
          anyDuplicated(labels[[1]]) ||
          anyDuplicated(labels[[2]])
      ) {
        stop(
          sprintf(
            "Weights for `%s` must have unique category names on both axes.",
            attribute
          ),
          call. = FALSE
        )
      }
      values <- as.character(present[[attribute]])
      if (
        anyNA(values) ||
          !all(values %in% labels[[1]]) ||
          !all(values %in% labels[[2]])
      ) {
        stop(
          sprintf(
            "Weights for `%s` must cover all contact IDs' non-missing categories.",
            attribute
          ),
          call. = FALSE
        )
      }

      # Expand category coefficients to person pairs and multiply element-wise.
      result * coefficients[values, values, drop = FALSE]
    },
    .init = contacts
  )
}
