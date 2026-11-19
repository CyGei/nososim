# Shared group identities, ordering and counts for transmission plots.
transmission_groups <- function(x, by) {
  stopifnot(
    "`by` must name one or more distinct population attributes." =
      is.character(by) && length(by) > 0L && !anyNA(by) &&
      !anyDuplicated(by) && all(by %in% names(x$population))
  )
  edges <- count_edges(x, by)
  groups <- x$population |>
    dplyr::distinct(dplyr::across(dplyr::all_of(by))) |>
    dplyr::arrange(dplyr::across(dplyr::all_of(by)))
  labels <- groups |>
    dplyr::mutate(dplyr::across(
      dplyr::everything(), ~ tidyr::replace_na(as.character(.x), "(Missing)")
    )) |>
    tidyr::unite(".label", dplyr::all_of(rev(by)), sep = "\r") |>
    dplyr::pull(".label")
  ids <- seq_len(nrow(groups))

  # Join on attributes, not display labels, to keep distinct groups distinct.
  endpoint <- function(side) {
    lookup <- groups
    names(lookup) <- paste0(side, "_", by)
    lookup$.group <- ids
    dplyr::left_join(edges, lookup,
      by = names(lookup)[seq_along(by)], relationship = "many-to-one"
    )$.group
  }
  counts <- tibble::tibble(
    source = factor(endpoint("source"), levels = ids),
    recipient = factor(endpoint("recipient"), levels = ids),
    transmissions = edges$transmissions
  )
  labels <- stats::setNames(labels, ids)
  list(counts = counts, groups = groups, labels = labels)
}
