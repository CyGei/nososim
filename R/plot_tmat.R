#' Plot a transmission matrix with nested groups
#'
#' @param x An outbreak returned by [make_outbreak()].
#' @param by Population attributes, ordered from outermost to innermost group.
#' @return A ggplot with sources on rows and recipients on columns.
#' @details Counts come from [count_edges()], using attributes on the
#'   transmission date and excluding imported cases. Both axes include all
#'   combinations observed in the population, including groups with no
#'   transmissions. Unused factor levels are omitted. Factor levels determine
#'   ordering; other attributes are sorted in ascending order. Missing attributes
#'   are labelled `(Missing)`. Cells with no transmissions display zero.
#' @export
#' @examples
#' plot_tmat(outbreak, by = "role")
#' plot_tmat(outbreak, by = c("level_2", "role"))
plot_tmat <- function(x, by) {
  data <- transmission_groups(x, by)
  counts <- tidyr::complete(
    data$counts, source = .data$source, recipient = .data$recipient,
    fill = list(transmissions = 0L)
  )
  labels <- data$labels
  ids <- seq_len(nrow(data$groups))
  axis <- function() {
    if (!length(ids)) "none"
    else if (length(by) == 1L) "axis"
    else legendry::guide_axis_nested(key = "\r")
  }

  ggplot(counts, aes(.data$recipient, .data$source)) +
    ggplot2::geom_tile(aes(fill = .data$transmissions), colour = "white") +
    ggplot2::geom_text(aes(label = .data$transmissions), colour = "white") +
    ggplot2::scale_x_discrete(
      labels = labels, drop = FALSE,
      guide = axis()
    ) +
    ggplot2::scale_y_discrete(
      labels = labels, limits = rev, drop = FALSE,
      guide = axis()
    ) +
    ggplot2::scale_fill_gradient() +
    ggplot2::coord_equal() +
    labs(x = "Recipient", y = "Source", fill = "Transmissions") +
    theme_classic()
}
