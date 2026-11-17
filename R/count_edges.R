#' Count transmissions by attributes
#'
#' Count edges between source and recipient groups, using their
#' attributes on the transmission date.
#' Imported cases are excluded.
#'
#' @param x An object of class `nososim_outbreak`.
#' @param by Population attributes to group by.
#' @param by_date Also group by infection date? Defaults to `FALSE`.
#' @return A tibble with source and recipient attributes and transmission counts,
#'   plus `date` when `by_date = TRUE`.
#' @export
#'
#' @examples
#' count_edges(outbreak, by = "ward")
#' count_edges(outbreak, by = "ward", by_date = TRUE)
#' count_edges(outbreak, by = c("ward", "role"))
count_edges <- function(x, by, by_date = FALSE) {
  stopifnot(is.character(by), length(by) > 0)

  edges <- x$infections |>
    dplyr::filter(!is.na(from))

  add_attributes <- function(edges, label, prefix) {
    attributes <- x$population[c("labels", "t", by)]
    names(attributes) <- c(label, "date", paste0(prefix, by))
    dplyr::left_join(edges, attributes,
      by = c(label, "date"),
      relationship = "many-to-one"
    )
  }

  edges |>
    add_attributes("from", "source_") |>
    add_attributes("to", "recipient_") |>
    dplyr::count(
      dplyr::across(dplyr::all_of(c(
        if (by_date) "date",
        paste0("source_", by),
        paste0("recipient_", by)
      ))),
      name = "transmissions"
    )
}
