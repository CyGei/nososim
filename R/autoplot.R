#' Plot population stays and available capacity
#'
#' @param object The population history returned by [make_outbreak()].
#' @param mapping Aesthetic mappings for stays, passed to [ggplot2::ggplot()].
#'   Defaults to colouring by individual `labels`.
#' @param ... Unused.
#' @details Each stay keeps one display row within its location until departure.
#'   Vacated rows may be reused; returning individuals retain their colour but
#'   may occupy a different row. The individual-colour legend is hidden to keep
#'   large populations readable; add `guides(colour = "legend")` to show it.
#' @return A ggplot with one row per unit of capacity, grouped by location.
#' @export
autoplot.nososim_population <- function(object, mapping = aes(colour = labels), ...) {
  rlang::check_dots_empty()
  positions <- population_positions(object)
  data <- positions$data
  slots <- positions$slots
  keys <- c(
    if (dplyr::n_distinct(slots$population) > 1L) "population",
    level_columns(slots)
  )
  labels <- apply(slots[keys], 1, function(x) {
    paste(c(" ", rev(replace(x, is.na(x), " "))), collapse = "\r")
  })
  colour_guide <- if (rlang::is_symbol(rlang::get_expr(mapping$colour), "labels")) {
    "none"
  } else {
    "legend"
  }

  ggplot(data, mapping) +
    aes(y = .y) +
    ggplot2::geom_hline(
      data = slots,
      aes(yintercept = .y),
      colour = "grey90",
      linewidth = 0.4,
      inherit.aes = FALSE
    ) +
    geom_segment(
      aes(x = t, xend = t + 1, yend = .y),
      linewidth = 2,
      lineend = "square"
    ) +
    ggplot2::scale_y_discrete(
      limits = if (nrow(slots)) levels(slots$.y) else NULL,
      labels = stats::setNames(labels, as.character(slots$.y)),
      guide = if (nrow(slots)) {
        legendry::guide_axis_nested(key = "\r", drop_zero = FALSE)
      } else {
        "none"
      }
    ) +
    scale_x_date(
      limits = range(c(attr(object, "dates"), data$t + 1))
    ) +
    ggplot2::guides(colour = colour_guide) +
    labs(x = "Date", y = NULL) +
    theme_classic() +
    theme(axis.ticks.y = element_blank(), legend.position = "top")
}

#' Plot stays with an outbreak's transmission history
#'
#' @param object An outbreak returned by [make_outbreak()].
#' @inheritParams autoplot.nososim_population
#' @details Reuses [autoplot.nososim_population()] for the stays. Arrows connect
#'   the source's infection point to the recipient's infection point, using each
#'   person's date and location at infection. These show ancestry even if the
#'   source later changes location. Diamonds mark imported cases, which have
#'   no source arrow.
#' @return A ggplot of stays with transmission arrows and infection points.
#' @export
#' @examples
#' autoplot(outbreak)
#' autoplot(outbreak, ggplot2::aes(colour = role))
autoplot.nososim_outbreak <- function(object, mapping = aes(colour = labels), ...) {
  rlang::check_dots_empty()
  plot <- autoplot(object$population, mapping)
  if (!nrow(object$infections)) {
    return(plot)
  }
  positions <- plot$data[c("labels", "t", ".y")]
  infections <- object$infections |>
    left_join(positions,
      by = c("to" = "labels", "date" = "t"),
      relationship = "many-to-one"
    )
  edges <- infections |>
    filter(!is.na(from)) |>
    left_join(
      transmute(infections, from = to, .date = date, .from = .y),
      by = "from",
      relationship = "many-to-one"
    )

  plot +
    geom_segment(
      data = edges,
      aes(x = .data$.date, xend = date, y = .data$.from, yend = .y),
      linewidth = 0.35, colour = "grey20",
      arrow = ggplot2::arrow(length = ggplot2::unit(2, "mm"), type = "closed"),
      inherit.aes = FALSE
    ) +
    ggplot2::geom_point(
      data = infections,
      aes(x = date, y = .y, shape = ifelse(is.na(from), "Imported", "Local")),
      size = 2, fill = "white", colour = "grey20",
      inherit.aes = FALSE
    ) +
    ggplot2::scale_shape_manual(
      name = "Infection", values = c(Imported = 23, Local = 21)
    )
}

#' Assign stays to available display rows within each location
#' @noRd
population_positions <- function(object) {
  landscape <- attr(object, "landscape")
  keys <- c("population", level_columns(landscape))
  slots <- tidyr::uncount(landscape[c(keys, "capacity")], capacity)
  slots$.y <- factor(
    seq_len(nrow(slots)),
    levels = rev(seq_len(nrow(slots)))
  )
  data <- tibble::as_tibble(object)
  lookup <- landscape[keys]
  lookup$.location <- seq_len(nrow(landscape))
  episodes <- data |>
    left_join(lookup, by = keys, relationship = "many-to-one") |>
    dplyr::arrange(t) |>
    dplyr::summarise(
      first = dplyr::first(t),
      last = dplyr::last(t),
      .by = c(labels, start, population, .location)
    )

  where <- rep(seq_len(nrow(landscape)), landscape$capacity)
  until <- rep(-Inf, nrow(slots))
  slot <- integer(nrow(episodes))
  for (i in order(episodes$first)) {
    free <- which(
      where == episodes$.location[i] & until < as.numeric(episodes$first[i])
    )
    if (!length(free)) {
      stop("Stays exceed the available capacity.")
    }
    slot[i] <- free[1L]
    until[slot[i]] <- as.numeric(episodes$last[i])
  }
  episodes$.y <- slots$.y[slot]
  data <- left_join(
    data,
    episodes[c("labels", "start", "population", ".y")],
    by = c("labels", "start", "population"),
    relationship = "many-to-one"
  )
  list(data = data, slots = slots)
}
