#' Build a transmission multiplier matrix
#'
#' Expand attribute multipliers to individual pairs, multiplying across attributes.
#'
#' @param data Current occupants, with unique `labels` and attribute columns.
#' @param multipliers Optional named list of numeric matrices, as in
#'   [get_contacts()]. Rows name source categories; columns name recipient
#'   categories. Values must be finite and non-negative. Category names must
#'   cover all observed values on both axes; missing attributes are errors.
#'   `NULL` or an empty list returns an all-ones matrix.
#' @return A matrix in `data` row order, with source labels in rows and recipient
#'   labels in columns. One means unchanged transmission, zero blocks it, and
#'   values above one increase it. No location matching or diagonal removal is
#'   applied; contacts determine which pairs can transmit.
#' @details [make_outbreak()] multiplies contacts by this matrix element by
#'   element, after optional contact sampling. Omitting its `intervention`
#'   callback is equivalent to returning all ones.
#' @seealso [make_outbreak()]
#' @export
#' @examples
#' data <- tibble::tibble(
#'   labels = c("a", "b", "c"),
#'   ward = c("ICU", "ICU", "General"),
#'   vaccinated = c(FALSE, TRUE, TRUE)
#' )
#' wards <- c("ICU", "General")
#' status <- c("FALSE", "TRUE")
#' get_intervention(data, multipliers = list(
#'   ward = matrix(c(0.7, 1, 1, 1), 2, byrow = TRUE,
#'     dimnames = list(wards, wards)),
#'   vaccinated = matrix(c(1, 0.5, 1, 0.5), 2, byrow = TRUE,
#'     dimnames = list(status, status))
#' ))
get_intervention <- function(data, multipliers = NULL) {
  check_labels(data$labels)
  mixing_matrix(data, multipliers)
}
