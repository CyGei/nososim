#' Create a landscape
#'
#' Converts named locations and their numbers of places (`n`) into a table.
#' Columns `location_1`, `location_2`, etc. retain the hierarchy, in input order.
#'
#' @param landscape Named nested list with non-negative integer numbers of
#'   places (`n`) at its leaves.
#' @return A tibble with location columns and `n`.
#' @importFrom rlang :=
#' @export
#' @examples
#' make_landscape(list(H1 = list(A = c(a = 2, b = 3))))
make_landscape <- function(landscape) {
  flatten <- function(x, path = character()) {
    stopifnot(
      is.list(x) || is.numeric(x),
      length(x) > 0,
      rlang::is_named(x),
      !anyDuplicated(names(x))
    )
    if (is.list(x)) {
      return(
        imap(x, function(value, name) flatten(value, c(path, name))) |>
          bind_rows()
      )
    }
    stopifnot(all(is.finite(x)), all(x >= 0), all(x == floor(x)))
    tibble(
      !!!stats::setNames(
        as.list(path),
        sprintf("location_%d", seq_along(path))
      ),
      !!paste0("location_", length(path) + 1L) := names(x),
      n = unname(x)
    )
  }
  flatten(landscape) |>
    select(-n, n)
}
