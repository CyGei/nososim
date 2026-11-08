#' @rdname autoplot.nososim_timeline
#' @export
autoplot.nososim_population <- function(object, mapping = aes(), ...) {
  rlang::check_dots_empty()
  positions <- population_positions(object)
  data <- positions$data
  slots <- positions$slots
  keys <- grep("^location_[0-9]+$", names(slots), value = TRUE)
  labels <- apply(slots[keys], 1, function(x) {
    paste(c(" ", rev(replace(x, is.na(x), " "))), collapse = "\r")
  })

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
      aes(x = start, xend = end + 1, yend = .y),
      linewidth = 2.3,
      colour = "black",
      lineend = "square"
    ) +
    geom_segment(
      aes(x = start, xend = end + 1, yend = .y),
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
      limits = range(c(attr(object, "dates"), data$start, data$end + 1))
      # date_breaks = "2 days",
      # date_labels = "%d %b"
    ) +
    labs(x = "Date", y = NULL) +
    theme_classic() +
    theme(axis.ticks.y = element_blank(), legend.position = "top")
}

#' Assign stays to available display rows within each location
#' @noRd
population_positions <- function(object) {
  landscape <- attr(object, "landscape")
  keys <- grep("^location_[0-9]+$", names(landscape), value = TRUE)
  slots <- tidyr::uncount(landscape[c(keys, "n")], n)
  slots$.y <- factor(
    seq_len(nrow(slots)),
    levels = rev(seq_len(nrow(slots)))
  )
  data <- tibble::as_tibble(object)
  index <- integer(nrow(data))
  if (nrow(data)) {
    lookup <- landscape[keys]
    lookup$.location <- seq_len(nrow(landscape))
    index <- left_join(
      data[keys],
      lookup,
      by = keys,
      relationship = "many-to-one"
    )$.location
    stopifnot(!anyNA(index), all(data$end >= data$start))
  } else {
    data$start <- data$end <- attr(object, "dates")[0]
  }

  where <- rep(seq_len(nrow(landscape)), landscape$n)
  until <- rep(-Inf, nrow(slots))
  slot <- integer(nrow(data))
  for (i in order(data$start)) {
    free <- which(where == index[i] & until < as.numeric(data$start[i]))
    if (!length(free)) {
      stop("Stays exceed the available capacity.")
    }
    slot[i] <- free[1L]
    until[slot[i]] <- as.numeric(data$end[i])
  }
  data$.y <- slots$.y[slot]
  list(data = data, slots = slots)
}
