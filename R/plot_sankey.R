#' Plot transmission flows with nested groups
#'
#' @inheritParams plot_tmat
#' @return A ggplot with sources on the left and recipients on the right.
#' @details Counts come from [count_edges()], using attributes on the
#'   transmission date and excluding imported cases. Each ribbon represents
#'   one complete source-group to recipient-group combination. Its thickness
#'   is the number of transmission events, not the number of distinct infectors
#'   or a transmission rate. Colours identify the first `by` attribute that
#'   varies among sources (or the first attribute if none vary) and stay fixed
#'   along each ribbon.
#'
#'   Groups with no outgoing or incoming transmissions are omitted on the
#'   corresponding side. Factor levels determine ordering from top to bottom;
#'   other attributes are sorted in ascending order. Missing attributes are
#'   labelled `(Missing)`. Both columns use the same count scale.
#'   Category labels are vertical. A numeric
#'   transmission axis sits outside the source hierarchy.
#' @seealso [plot_tmat()]
#' @export
#' @examples
#' plot_sankey(outbreak, by = c("level_2", "role"))
#' plot_sankey(outbreak, by = c("level_1", "level_2", "role"))
plot_sankey <- function(x, by) {
  data <- transmission_groups(x, by)
  flows <- data$counts

  positions <- sankey_layout(data, by)
  nodes <- positions$nodes
  axes <- positions$axes
  plot <- ggplot(flows) +
    ggalluvial::geom_alluvium(
      data = positions$lodes,
      aes(
        x = .data$x,
        y = .data$transmissions,
        stratum = .data$node,
        alluvium = .data$flow,
        fill = .data$origin
      ),
      width = 0.08,
      reverse = TRUE,
      decreasing = NA,
      aes.bind = "none",
      curve_type = "cubic",
      alpha = 0.75,
      colour = "white",
      linewidth = 0.2
    ) +
    ggplot2::geom_rect(
      data = nodes,
      aes(
        xmin = .data$x - 0.04,
        xmax = .data$x + 0.04,
        ymin = .data$ymin,
        ymax = .data$ymax
      ),
      fill = "#F5F5F2",
      colour = "#858D8C",
      linewidth = 0.35
    ) +
    ggplot2::scale_fill_hue(
      c = 55,
      l = 55,
      labels = positions$colours,
      name = paste("Source", positions$colour_by)
    ) +
    ggplot2::guides(fill = "none") +
    labs(x = NULL, y = NULL) +
    theme_classic() +
    theme(axis.line = element_blank(), axis.ticks = element_blank())

  source <- nodes[nodes$x == axes$x[1L], ]
  recipient <- nodes[nodes$x == axes$x[2L], ]
  total <- sum(flows$transmissions)
  ticks <- unique(c(pretty(c(0, total)), total))
  ticks <- ticks[ticks >= 0 & ticks <= total & ticks == floor(ticks)]
  plot +
    ggplot2::scale_x_continuous(
      breaks = axes$x,
      labels = c("Source", "Recipient"),
      guide = ggplot2::guide_axis(angle = 90),
      position = "top",
      expand = ggplot2::expansion(add = 0.04)
    ) +
    ggplot2::scale_y_continuous(
      breaks = (source$ymin + source$ymax) / 2,
      labels = source$name,
      guide = legendry::compose_stack(
        sankey_axis(source, data$groups, by),
        legendry::guide_axis_base(key = legendry::key_manual(ticks), angle = 0),
        side.titles = NULL
      ),
      sec.axis = ggplot2::dup_axis(
        breaks = (recipient$ymin + recipient$ymax) / 2,
        labels = recipient$name,
        name = NULL,
        guide = sankey_axis(recipient, data$groups, by)
      ),
      expand = ggplot2::expansion(mult = 0.02)
    ) +
    labs(y = "Transmissions")
}

sankey_axis <- function(nodes, groups, by) {
  if (length(by) == 1L) {
    return(legendry::guide_axis_base(angle = 90))
  }
  positions <- groups[nodes$group, , drop = FALSE]
  positions$.ymin <- nodes$ymin
  positions$.ymax <- nodes$ymax
  # legendry stacks levels in input order, starting nearest the panel.
  ranges <- lapply(rev(seq_len(length(by) - 1L)), function(depth) {
    parents <- positions |>
      dplyr::group_by(dplyr::across(dplyr::all_of(by[seq_len(depth)]))) |>
      dplyr::summarise(
        .start = min(.data$.ymin),
        .end = max(.data$.ymax),
        .groups = "drop"
      )
    legendry::key_range_manual(
      start = parents$.start,
      end = parents$.end,
      name = tidyr::replace_na(as.character(parents[[by[depth]]]), "(Missing)"),
      level = length(by) - depth
    )
  })
  legendry::guide_axis_nested(key = dplyr::bind_rows(ranges), angle = 90)
}
