#' Create a landscape
#'
#' Converts a nested named list with one integer capacity per leaf
#' into a tibble with level columns and `capacity`.
#'
#'
#' @param landscape A nested named list with one non-negative integer capacity per leaf.
#' @return A tibble with level columns and `capacity`.
#' @export
#' @examples
#' make_landscape(list(H1 = list(A = list(a = 2, b = 3))))
make_landscape <- function(landscape) {
  stopifnot(is.list(landscape))

  collect <- function(x, path = character()) {
    if (!is.list(x)) {
      stopifnot(length(x) == 1L)
      return(tibble::tibble(level = list(path), capacity = x))
    }

    stopifnot(length(x) > 0, rlang::is_named(x))
    purrr::imap(x, function(child, name) {
      collect(child, c(path, name))
    }) |>
      dplyr::bind_rows()
  }

  collect(landscape) |>
    tidyr::unnest_wider(level, names_sep = "_")
}
