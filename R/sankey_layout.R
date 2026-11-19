# Position complete source and recipient groups in two columns.
sankey_layout <- function(data, by) {
  flows <- data$counts
  groups <- data$groups
  axes <- tibble::tibble(side = c("source", "recipient"), x = c(1, 2.6))
  source_groups <- groups[as.integer(flows$source), , drop = FALSE]
  varying <- vapply(source_groups, dplyr::n_distinct, integer(1)) > 1L
  colour_by <- if (any(varying)) by[which(varying)[1L]] else by[1L]
  outer <- unique(groups[[colour_by]])
  origin <- match(source_groups[[colour_by]], outer)
  colours <- stats::setNames(
    tidyr::replace_na(as.character(outer), "(Missing)"), seq_along(outer)
  )
  lodes <- lapply(seq_len(nrow(axes)), function(i) {
    group <- as.integer(flows[[axes$side[i]]])
    tibble::tibble(
      x = axes$x[i], group = group,
      node = factor(paste(i, group, sep = ":"),
                    levels = paste(i, seq_len(nrow(groups)), sep = ":")),
      name = tidyr::replace_na(as.character(groups[[by[length(by)]]][group]), "(Missing)"),
      flow = seq_len(nrow(flows)),
      origin = factor(origin, levels = seq_along(outer)),
      transmissions = flows$transmissions
    )
  }) |>
    dplyr::bind_rows()
  nodes <- lodes |>
    dplyr::group_by(.data$x, .data$group, .data$node, .data$name) |>
    dplyr::summarise(transmissions = sum(.data$transmissions), .groups = "drop") |>
    dplyr::group_by(.data$x) |>
    dplyr::mutate(
      ymin = sum(.data$transmissions) - cumsum(.data$transmissions),
      ymax = .data$ymin + .data$transmissions
    ) |>
    dplyr::ungroup()
  list(lodes = lodes, nodes = nodes, axes = axes,
       colours = colours, colour_by = colour_by)
}
