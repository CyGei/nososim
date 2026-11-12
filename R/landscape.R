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
      length(x) > 0,
      rlang::is_named(x),
      !anyDuplicated(names(x))
    )

    if (is.list(x)) {
      purrr::imap(x, function(child, name) {
        collect_levels(child, path = c(path, name))
      }) |>
        dplyr::bind_rows()
    } else {
      check_counts(x)
      tibble::tibble(
        level = purrr::map(names(x), function(name) c(path, name)),
        capacity = unname(x)
      )
    }
  }

  collect_levels(landscape) |>
    tidyr::unnest_wider(level, names_sep = "_")
}
