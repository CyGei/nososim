#' Plot a population timeline or outbreak
#'
#' @param object A timeline or outbreak from [make_timeline()] or [make_outbreak()].
#' @param mapping Additional aesthetics from [ggplot2::aes()].
#' @param ... Unused.
#' @return A ggplot showing daily presence, with infection links for outbreaks.
#' @export
#' @examples
#' timeline <- make_timeline(2, as.Date("2026-01-01") + 0:6)
#' autoplot(timeline)
autoplot.nososim_timeline <- function(object, mapping = aes(), ...) {
  rlang::check_dots_empty()
  tibble::as_tibble(object) |>
    mutate(id = factor(id, levels = rev(unique(id)))) |>
    ggplot(mapping) +
    aes(y = id) +
    geom_segment(
      aes(x = date, xend = date + 1, yend = id),
      linewidth = 2,
      lineend = "round"
    ) +
    scale_x_date(date_breaks = "2 days", date_labels = "%d %b") +
    labs(x = "Date", y = NULL) +
    theme_classic() +
    theme(
      panel.grid.major.y = element_line(
        colour = "grey85",
        linewidth = 0.3
      ),
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      legend.position = "top"
    )
}

#' @rdname autoplot.nososim_timeline
#' @export
autoplot.nososim_outbreak <- function(object, mapping = aes(), ...) {
  rlang::check_dots_empty()
  timeline <- tibble::as_tibble(object$timeline)
  infections <- object$infections
  point_mapping <- aes(x = date_infection, shape = I(21))
  if (!is.null(mapping$shape)) {
    point_mapping$shape <- mapping$shape
  }

  events <- infections |>
    mutate(source_date = date_infection[match(source, id)]) |>
    left_join(timeline, by = c("id", "date_infection" = "date"))

  autoplot(object$timeline, mapping = mapping) +
    ggarrow::geom_arrow_segment(
      data = filter(events, !is.na(source)),
      aes(x = source_date, xend = date_infection, y = source, yend = id),
      length_head = grid::unit(2, "mm"),
      resect_head = grid::unit(2, "mm"),
      linewidth = 0.5,
      inherit.aes = FALSE,
      colour = "black"
    ) +
    geom_point(
      data = events,
      point_mapping,
      colour = "black",
      show.legend = c(colour = FALSE, fill = FALSE),
      size = 3
    )
}
