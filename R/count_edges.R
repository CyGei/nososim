#' Count transmissions by attributes
#'
#' Count edges between source and recipient groups, using their
#' attributes on the recipient's infection date. Initial cases are excluded.
#'
#' @param x An object of class `nososim_outbreak`.
#' @param by Timeline attributes to group by.
#' @param by_date Also group by infection date? Defaults to `FALSE`.
#' @return A tibble with source and recipient attributes and transmission counts,
#'   plus `date_infection` when `by_date = TRUE`.
#' @export
#'
#' @examples
#' count_edges(outbreak, by = "ward")
#' count_edges(outbreak, by = "ward", by_date = TRUE)
#' count_edges(outbreak, by = c("ward", "role"))
count_edges <- function(x, by, by_date = FALSE) {
  stopifnot(inherits(x, "nososim_outbreak"))
  stopifnot(is.logical(by_date), length(by_date) == 1L, !is.na(by_date))
  stopifnot(
    is.character(by),
    length(by) > 0,
    !anyNA(by),
    !anyDuplicated(by),
    all(by %in% setdiff(names(x$timeline), c("id", "date", "R_i")))
  )

  edges <- dplyr::filter(x$infections, !is.na(source))

  add_attributes <- function(edges, id, prefix) {
    attributes <- x$timeline[c("id", "date", by)]
    names(attributes) <- c(id, "date_infection", paste0(prefix, by))
    dplyr::left_join(edges, attributes, by = c(id, "date_infection"))
  }

  edges |>
    add_attributes("source", "source_") |>
    add_attributes("id", "recipient_") |>
    dplyr::count(
      dplyr::across(dplyr::all_of(c(
        if (by_date) "date_infection",
        paste0("source_", by),
        paste0("recipient_", by)
      ))),
      name = "transmissions"
    )
}
