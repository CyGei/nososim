#' Create a landscape
#'
#' Converts named locations and their capacities (`n`) into a table.
#' Columns `location_1`, `location_2`, etc. retain the hierarchy, in input order.
#'
#' @param landscape Named nested list with non-negative integer capacities
#'   (`n`) at its leaves.
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
      branches <- imap(x, function(value, name) {
        flatten(value, c(path, name))
      })
      return(bind_rows(branches))
    }

    stopifnot(
      all(is.finite(x)),
      all(x >= 0),
      all(x == floor(x))
    )

    columns <- lapply(path, function(name) rep(name, length(x)))
    columns <- append(columns, list(names(x)))
    names(columns) <- paste0("location_", seq_along(columns))

    columns$n <- unname(x)
    tibble::as_tibble(columns)
  }

  flatten(landscape) |>
    select(-n, n)
}
