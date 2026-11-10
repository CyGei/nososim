#' Create a landscape
#'
#' Converts named locations and their capacities (`capacity`) into a table.
#' Columns `level_1`, `level_2`, etc. retain the hierarchy, in input order.
#'
#' @param landscape Named nested list with non-negative integer capacities
#'   (`capacity`) at its leaves.
#' @return A tibble with level columns and `capacity`.
#' @importFrom rlang :=
#' @export
#' @examples
#' make_landscape(list(H1 = list(A = c(a = 2, b = 3))))
make_landscape <- function(landscape) {
  collect_levels <- function(x, path = character()) {
    stopifnot(
      is.list(x) || is.numeric(x),
      length(x) > 0,
      rlang::is_named(x),
      !anyDuplicated(names(x))
    )

    # A list contains more levels: visit each child.
    if (is.list(x)) {
      branches <- purrr::imap(x, function(child, name) {
        collect_levels(child, path = c(path, name))
      })
      return(dplyr::bind_rows(branches))
    }

    # A numeric vector contains the final locations and capacities.
    stopifnot(
      all(is.finite(x)),
      all(x >= 0),
      all(x == floor(x))
    )

    tibble::tibble(
      level = purrr::map(names(x), function(name) c(path, name)),
      capacity = unname(x)
    )
  }

  collect_levels(landscape) |>
    tidyr::unnest_wider(level, names_sep = "_")
}
