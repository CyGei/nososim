#' @rdname autoplot.nososim_timeline
#' @export
autoplot.nososim_population <- function(object, mapping = aes(), ...) {
  rlang::check_dots_empty()
  positions <- population_positions(object)
  data <- positions$data
  places <- positions$places
  keys <- grep("^location_[0-9]+$", names(places), value = TRUE)
  labels <- apply(places[keys], 1, function(x) {
    paste(c(" ", rev(replace(x, is.na(x), " "))), collapse = "\r")
  })

  ggplot(data, mapping) +
    aes(y = .y) +
    ggplot2::geom_hline(
      data = places,
      aes(yintercept = .y),
      colour = "grey90",
      linewidth = 0.4,
      inherit.aes = FALSE
    ) +
    geom_segment(
      aes(x = start, xend = end, yend = .y),
      linewidth = 2,
      lineend = "round"
    ) +
    ggplot2::scale_y_discrete(
      limits = if (nrow(places)) levels(places$.y) else NULL,
      labels = stats::setNames(labels, as.character(places$.y)),
      guide = if (nrow(places)) {
        legendry::guide_axis_nested(key = "\r", drop_zero = FALSE)
      } else {
        "none"
      }
    ) +
    scale_x_date(
      limits = range(c(attr(object, "dates"), data$start, data$end)),
      date_breaks = "2 days",
      date_labels = "%d %b"
    ) +
    labs(x = "Date", y = NULL) +
    theme_classic() +
    theme(axis.ticks.y = element_blank(), legend.position = "top")
}

#' Assign stays to available display rows within each location
#' @noRd
population_positions <- function(object) {
  locations <- attr(object, "locations")
  keys <- grep("^location_[0-9]+$", names(locations), value = TRUE)
  places <- tidyr::uncount(locations[c(keys, "n")], n)
  places$.y <- factor(
    seq_len(nrow(places)),
    levels = rev(seq_len(nrow(places)))
  )
  data <- tibble::as_tibble(object)
  index <- integer(nrow(data))
  if (nrow(data)) {
    lookup <- locations[keys]
    lookup$.location <- seq_len(nrow(locations))
    index <- left_join(
      data[keys],
      lookup,
      by = keys,
      relationship = "many-to-one"
    )$.location
    stopifnot(!anyNA(index), all(data$end > data$start))
  } else {
    data$start <- data$end <- attr(object, "dates")[0]
  }

  where <- rep(seq_len(nrow(locations)), locations$n)
  until <- rep(-Inf, nrow(places))
  slot <- integer(nrow(data))
  for (i in order(data$start)) {
    free <- which(where == index[i] & until <= as.numeric(data$start[i]))
    if (!length(free)) {
      stop("Stays exceed the available places.")
    }
    slot[i] <- free[1L]
    until[slot[i]] <- as.numeric(data$end[i])
  }
  data$.y <- places$.y[slot]
  list(data = data, places = places)
}
