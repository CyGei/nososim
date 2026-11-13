#' Count transmissions by attributes
#'
#' Count edges between source and recipient groups, using their
#' attributes on the contact date (the day before the recorded infection date).
#' Imported cases are excluded.
#'
#' @param x An object of class `nososim_outbreak`.
#' @param by Population attributes to group by.
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
  stopifnot(is.character(by), length(by) > 0)

  edges <- x$infections |>
    dplyr::filter(!is.na(source)) |>
    dplyr::mutate(date_contact = date_infection - 1L)

  add_attributes <- function(edges, id, prefix) {
    attributes <- x$population[c("id", "start", "end", by)]
    names(attributes) <- c(id, "start", "end", paste0(prefix, by))
    dplyr::left_join(edges, attributes,
      by = dplyr::join_by(
        !!rlang::sym(id), date_contact >= start, date_contact <= end
      ),
      relationship = "many-to-one"
    ) |>
      dplyr::select(-start, -end)
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
