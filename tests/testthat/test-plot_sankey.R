sankey_outbreak <- function() {
  dates <- as.Date("2026-01-01") + 0:1
  structure(list(
    population = tibble::tibble(
      labels = rep(letters[1:4], 2), t = rep(dates, each = 4),
      hospital = "Hospital",
      ward = factor(c("A", "B", "A", "B", "B", "B", "A", "B"),
        levels = c("B", "A", "unused")),
      role = rep(c("staff", "patient", "patient", "patient"), 2)
    ),
    infections = tibble::tibble(
      from = c(NA, "a", "a", "a"), to = letters[1:4],
      date = dates[c(1, 1, 2, 1)]
    )
  ), class = "nososim_outbreak")
}

test_that("Sankey widths conserve transmission-day counts on both sides", {
  outbreak <- sankey_outbreak()
  plot <- plot_sankey(outbreak, c("ward", "role"))
  flows <- plot$data
  expect_s3_class(plot, "ggplot")
  expect_equal(sum(flows$transmissions), 3L)
  expect_equal(as.character(flows$source), c("2", "4"))
  expect_equal(as.character(flows$recipient), c("3", "1"))
  expect_equal(flows$transmissions, c(1L, 2L))
  matrix <- plot_tmat(outbreak, c("ward", "role"))$data
  expect_equal(flows[c("source", "recipient", "transmissions")],
    matrix[matrix$transmissions > 0, ])

  # Source-only and recipient-only groups get independent positions and labels.
  scale <- plot$scales$get_scales("y")
  expect_equal(scale$labels, c("staff", "staff"))
  expect_equal(scale$secondary.axis$labels, c("patient", "patient"))
  expect_equal(diff(scale$breaks), -1.5)
  expect_no_warning(ggplot2::ggplotGrob(plot))

  built <- ggplot2::ggplot_build(plot)
  ribbons <- built$data[[1]]
  expect_equal(ribbons$ymax - ribbons$ymin,
    flows$transmissions[ribbons$alluvium])
  nodes <- built$data[[2]]
  expect_equal(nodes$ymax - nodes$ymin, c(1, 2, 2, 1))
})

test_that("Sankey single groups, deeper nesting and missing values render", {
  outbreak <- sankey_outbreak()
  outbreak$population$ward[1] <- NA
  plot <- plot_sankey(outbreak, "ward")
  expect_true(any(startsWith(plot$scales$get_scales("y")$labels, "(Missing)")))
  expect_no_warning(ggplot2::ggplotGrob(plot))
  expect_no_warning(ggplot2::ggplotGrob(
    plot_sankey(outbreak, c("hospital", "ward", "role"))
  ))

  # A flow within one group remains a ribbon between the two sides.
  plot <- plot_sankey(outbreak, "hospital")
  expect_equal(plot$data$transmissions, 3L)
  expect_no_warning(ggplot2::ggplotGrob(plot))
})

test_that("Sankey rejects invalid attributes", {
  outbreak <- sankey_outbreak()
  for (by in list(character(), c("role", "role"), NA_character_, "absent")) {
    expect_error(plot_sankey(outbreak, by), "distinct population attributes")
  }
})

test_that("nested groups retain parent identities and conserve every flow", {
  outbreak <- sankey_outbreak()
  by <- c("hospital", "ward", "role")
  plot <- plot_sankey(outbreak, by)
  expect_no_warning(ggplot2::ggplotGrob(plot))
  lodes <- plot$layers[[1]]$data
  nodes <- plot$layers[[2]]$data

  # The two 'staff' leaves belong to different wards and must stay separate.
  leaves <- nodes[nodes$x == 1, ]
  expect_equal(leaves$name, c("staff", "staff"))
  expect_equal(dplyr::n_distinct(leaves$node), 2L)
  expect_equal(leaves$transmissions, c(1L, 2L))
  expect_equal(length(unique(lodes$x)), 2L)
  expect_equal(as.vector(tapply(nodes$transmissions, nodes$x, sum)), rep(3L, 2))
  expect_equal(as.vector(tapply(lodes$transmissions, lodes$x, sum)), rep(3L, 2))
  # Skip the constant hospital attribute when choosing the source colours.
  expect_equal(plot$scales$get_scales("fill")$name, "Source ward")

  built <- ggplot2::ggplot_build(plot)$data[[1]]
  expect_equal(built$ymax - built$ymin,
    plot$data$transmissions[built$alluvium])
  for (id in unique(built$alluvium)) {
    flow <- built[built$alluvium == id, ]
    expect_equal(length(unique(flow$fill)), 1L)
  }
})

test_that("source colour represents a parent consistently across child groups", {
  outbreak <- sankey_outbreak()
  outbreak$infections$from[4] <- "b"
  plot <- plot_sankey(outbreak, c("ward", "role"))
  lodes <- plot$layers[[1]]$data
  source <- lodes[lodes$x == min(lodes$x), ]
  # Ward B's patient and staff leaves use the same colour.
  expect_equal(source$origin[source$group == 1L], source$origin[source$group == 2L])
  expect_no_warning(ggplot2::ggplotGrob(plot))
})

test_that("rendered nested axes put the first by attribute outermost", {
  outbreak <- sankey_outbreak()
  outbreak$population <- tidyr::expand_grid(
    city = c("Gallen", "Geneva"), ward = c("General", "ICU"),
    role = c("patient", "staff")
  ) |>
    dplyr::mutate(labels = letters[1:8], t = as.Date("2026-01-01"))
  outbreak$infections <- tibble::tibble(
    from = rep(letters[1:8], 1:8), to = rep(letters[c(4:8, 1:3)], 1:8),
    date = as.Date("2026-01-01")
  )
  text_labels <- function(grob) {
    if (inherits(grob, "text")) return(list(grob$label))
    unlist(lapply(c(grob$grobs, grob$children), text_labels), recursive = FALSE)
  }
  for (by in list(c("city", "ward", "role"), c("ward", "city", "role"))) {
    plot <- plot_sankey(outbreak, by)
    drawing <- ggplot2::ggplotGrob(plot)
    left <- text_labels(drawing$grobs[[which(drawing$layout$name == "axis-l")]])
    right <- text_labels(drawing$grobs[[which(drawing$layout$name == "axis-r")]])
    numeric_labels <- vapply(left, function(x) all(grepl("^[0-9]+$", x)), logical(1))
    expect_equal(sum(numeric_labels), 1L)
    expect_equal(as.numeric(left[numeric_labels][[1L]]), c(0, 10, 20, 30, 36))
    left <- left[!numeric_labels]
    outer <- sort(unique(outbreak$population[[by[1L]]]))
    inner <- rep(sort(unique(outbreak$population[[by[2L]]])), 2)
    # The bracket grobs run left-to-right; the two axes mirror each other.
    expect_equal(unname(left[-1L]), list(outer, inner))
    expect_equal(unname(right[-1L]), list(inner, outer))
  }
})
