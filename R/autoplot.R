#' Plot stays and an outbreak's transmission tree
#'
#' @param object An outbreak returned by [make_outbreak()].
#' @param mapping Aesthetic mappings. `colour` controls stays, `shape` controls
#'   infection nodes, and `label` adds text beside infection nodes. Node mappings
#'   use the person's attributes at infection. Defaults to colouring stays by
#'   individual `labels`, with no node text.
#' @param ... Unused.
#' @details A location with capacity X gets X horizontal rows.
#'   Returning agents reuse their previous row in that location when available;
#'   otherwise, they take the first free row. They keep it until departure,
#'   after which another agent can reuse it.
#'
#'   Arrows connect the source's infection point to the recipient's infection
#'   point, using each person's date and location at infection. Nodes have white
#'   fill and dark outlines. By default, diamonds mark imported cases, which have
#'   no source arrow, and circles mark local cases. A `shape` mapping replaces
#'   this distinction with up to five filled shapes; use
#'   [ggplot2::scale_shape_manual()] to customise them.
#' @return A ggplot of stays, available capacity, and the transmission tree.
#' @export
#' @examples
#' autoplot(outbreak)
#' autoplot(outbreak, ggplot2::aes(colour = role))
#' autoplot(outbreak, ggplot2::aes(
#'   colour = labels, shape = population, label = labels
#' ))
autoplot.nososim_outbreak <- function(
  object,
  mapping = aes(colour = labels),
  ...
) {
  rlang::check_dots_empty()
  node_mapping <- aes(x = date, y = .y)
  node_mapping$shape <- mapping$shape
  text_mapping <- aes(x = date, y = .y)
  text_mapping$label <- mapping$label
  mapping$shape <- mapping$label <- NULL
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
  colour_guide <- if (
    rlang::is_symbol(rlang::get_expr(mapping$colour), "labels")
  ) {
    "none"
  } else {
    "legend"
  }

  plot <- ggplot(data, mapping) +
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
      limits = range(c(object$dates, data$t + 1))
    ) +
    ggplot2::guides(colour = colour_guide) +
    labs(x = "Date", y = NULL) +
    theme_classic() +
    theme(axis.ticks.y = element_blank(), legend.position = "top")
  if (!nrow(object$infections)) {
    return(plot)
  }
  infections <- object$infections |>
    left_join(
      data,
      by = c("to" = "labels", "date" = "t"),
      keep = TRUE,
      relationship = "many-to-one"
    )
  edges <- infections |>
    filter(!is.na(from)) |>
    left_join(
      transmute(infections, from = to, .date = date, .from = .y),
      by = "from",
      relationship = "many-to-one"
    )

  if (is.null(node_mapping$shape)) {
    node_mapping$shape <- aes(shape = ifelse(is.na(from), "Imported", "Local"))$shape
    shape_scale <- ggplot2::scale_shape_manual(
      name = "Infection", values = c(Imported = 23, Local = 21)
    )
  } else {
    shape_scale <- ggplot2::scale_shape_manual(values = 21:25)
  }

  plot <- plot +
    geom_segment(
      data = edges,
      aes(x = .data$.date, xend = date, y = .data$.from, yend = .y),
      linewidth = 0.35,
      colour = "grey20",
      arrow = ggplot2::arrow(length = ggplot2::unit(2, "mm"), type = "closed"),
      inherit.aes = FALSE
    ) +
    ggplot2::geom_point(
      data = infections,
      node_mapping,
      size = 2,
      fill = "white",
      colour = "grey20",
      inherit.aes = FALSE
    ) +
    shape_scale
  if (!is.null(text_mapping$label)) {
    plot <- plot + ggplot2::geom_text(
      data = infections,
      text_mapping,
      colour = "grey20",
      size = 3,
      vjust = -1,
      show.legend = FALSE,
      inherit.aes = FALSE
    )
  }
  plot
}

#' Assign stays to available display rows within each location
#' @noRd
population_positions <- function(object) {
  landscape <- object$landscape
  keys <- c("population", level_columns(landscape))
  slots <- tidyr::uncount(landscape[c(keys, "capacity")], capacity)
  slots$.y <- factor(
    seq_len(nrow(slots)),
    levels = rev(seq_len(nrow(slots)))
  )
  data <- object$population
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
  # Remember each person's previous row separately for each location.
  person_location <- episodes |>
    dplyr::group_by(labels, .location) |>
    dplyr::group_indices()
  last_slot <- integer(nrow(episodes))
  for (i in order(episodes$first)) {
    free <- which(
      where == episodes$.location[i] & until < as.numeric(episodes$first[i])
    )
    if (!length(free)) {
      stop("Stays exceed the available capacity.")
    }
    previous <- last_slot[person_location[i]]
    slot[i] <- if (previous %in% free) previous else free[1L]
    last_slot[person_location[i]] <- slot[i]
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
