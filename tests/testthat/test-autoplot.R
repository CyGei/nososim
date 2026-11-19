plot_outbreak <- function() {
  landscape <- make_landscape(list(site = list(a = 2, b = 1, empty = 2)))
  landscape$population <- "patients"
  dates <- as.Date("2026-01-01") + 0:6
  # A leaves, C takes the vacated row, and A returns in another ward.
  population <- tibble::tibble(
    labels = c("a", "a", rep("b", 4), "c", "c", "a", "a"),
    t = dates[c(1, 2, 1:4, 3, 4, 3, 4)],
    start = dates[c(rep(1, 6), rep(3, 4))],
    population = "patients", level_1 = "site",
    level_2 = c(rep("a", 8), "b", "b")
  )
  infections <- tibble::tibble(
    from = c(NA_character_, "a", "c"), to = c("a", "c", "b"),
    date = dates[c(1, 3, 4)]
  )
  structure(list(
    population = population, landscape = landscape,
    infections = infections, dates = dates
  ), class = "nososim_outbreak")
}

test_that("timelines keep stable rows and transmission arrows join infection points", {
  outbreak <- plot_outbreak()
  plot <- autoplot(outbreak)
  layers <- ggplot2::ggplot_build(plot)$data
  stays <- layers[[2]]
  edges <- layers[[3]]
  points <- layers[[4]]

  expect_equal(nrow(layers[[1]]), 5L)
  expect_equal(stays$x, as.numeric(outbreak$population$t))
  expect_equal(stays$xend, stays$x + 1)
  expect_equal(
    as.character(plot$data$.y),
    as.character(c(1, 1, 2, 2, 2, 2, 1, 1, 3, 3))
  )
  expect_equal(length(unique(stays$colour[plot$data$labels == "a"])), 1L)
  # A's arrow starts at its infection point, even after A moves elsewhere.
  expect_equal(points$x, as.numeric(outbreak$infections$date))
  expect_equal(as.numeric(points$y), as.numeric(stays$y[c(1, 7, 6)]))
  expect_equal(edges$x, points$x[1:2])
  expect_equal(edges$xend, points$x[2:3])
  expect_equal(as.numeric(edges$y), as.numeric(points$y[1:2]))
  expect_equal(as.numeric(edges$yend), as.numeric(points$y[2:3]))
  expect_equal(points$shape, c(23, 21, 21))
})

test_that("returning agents prefer their previous row unless it is occupied", {
  outbreak <- plot_outbreak()
  # A starts in row 2 and returns when both rows are free. Later E occupies it.
  outbreak$population <- tibble::tibble(
    labels = c("b", "a", "a", "d", "e", "e", "a", "a"),
    t = outbreak$dates[c(1, 1, 3, 4, 4, 5, 5, 7)],
    start = outbreak$dates[c(1, 1, 3, 4, 4, 4, 5, 7)],
    population = "patients", level_1 = "site", level_2 = "a"
  )
  data <- population_positions(outbreak)$data

  expect_equal(as.character(data$.y[data$labels == "a"]), c("2", "2", "1", "1"))
  expect_equal(nrow(dplyr::distinct(data, t, .y)), nrow(data))
})

test_that("node mappings use infection snapshots without colouring nodes", {
  outbreak <- plot_outbreak()
  staff <- outbreak$population[1:2, ]
  staff$labels <- "staff_1"
  staff$population <- "staff"
  staff_landscape <- outbreak$landscape[1, ]
  staff_landscape$population <- "staff"
  staff_landscape$capacity <- 1L
  outbreak$population <- dplyr::bind_rows(outbreak$population, staff)
  outbreak$population$role <- paste0("role_", outbreak$population$t)
  outbreak$landscape <- dplyr::bind_rows(outbreak$landscape, staff_landscape)
  outbreak$infections <- dplyr::bind_rows(
    outbreak$infections,
    tibble::tibble(from = "a", to = "staff_1", date = outbreak$dates[2])
  )
  plot <- autoplot(outbreak, ggplot2::aes(
    colour = role, shape = population, label = paste(labels, role)
  ))
  layers <- ggplot2::ggplot_build(plot)$data
  points <- layers[[4]]
  text <- layers[[5]]

  expect_gt(length(unique(layers[[2]]$colour)), 1L)
  expect_equal(points$shape, c(21, 21, 21, 22))
  expect_true(all(points$fill == "white"))
  expect_true(all(points$colour == "grey20"))
  expect_true(all(text$colour == "grey20"))
  expect_equal(text$label, paste(
    outbreak$infections$to, paste0("role_", outbreak$infections$date)
  ))
  expect_equal(text$x, points$x)
  expect_equal(text$y, points$y)
  expect_no_warning(ggplot2::ggplotGrob(plot))
})

test_that("shape and label mappings are optional and evaluated only on nodes", {
  outbreak <- plot_outbreak()
  labelled <- autoplot(outbreak, ggplot2::aes(label = to))
  layers <- ggplot2::ggplot_build(labelled)$data
  expect_equal(layers[[4]]$shape, c(23, 21, 21))
  expect_equal(layers[[5]]$label, outbreak$infections$to)

  shaped <- autoplot(outbreak, ggplot2::aes(shape = is.na(from)))
  layers <- ggplot2::ggplot_build(shaped)$data
  expect_length(layers, 4L)
  expect_equal(layers[[4]]$shape, c(22, 21, 21))

  outbreak$infections <- outbreak$infections[0, ]
  expect_no_warning(ggplot2::ggplotGrob(autoplot(
    outbreak, ggplot2::aes(colour = labels, shape = population, label = to)
  )))
})

test_that("population groups have independent capacity at matching locations", {
  outbreak <- plot_outbreak()
  staff <- outbreak$population[1:2, ]
  staff$labels <- "staff_1"
  staff$population <- "staff"
  staff_landscape <- outbreak$landscape[1, ]
  staff_landscape$population <- "staff"
  staff_landscape$capacity <- 1L
  outbreak$population <- dplyr::bind_rows(outbreak$population, staff)
  outbreak$landscape <- dplyr::bind_rows(outbreak$landscape, staff_landscape)
  positions <- population_positions(outbreak)

  expect_equal(nrow(positions$slots), 6L)
  expect_equal(nrow(dplyr::distinct(positions$data, t, .y)), nrow(outbreak$population))
})

test_that("plots render with only imports, no infections, or no occupants", {
  withr::local_pdf(tempfile(fileext = ".pdf"))
  outbreak <- plot_outbreak()
  outbreak$infections <- outbreak$infections[1, ]
  expect_no_warning(ggplot2::ggplotGrob(autoplot(outbreak)))
  outbreak$infections <- outbreak$infections[0, ]
  expect_no_warning(ggplot2::ggplotGrob(autoplot(outbreak)))
  outbreak$population <- outbreak$population[0, ]
  plot <- autoplot(outbreak)
  layers <- ggplot2::ggplot_build(plot)$data

  expect_equal(nrow(layers[[1]]), 5L)
  expect_equal(nrow(layers[[2]]), 0L)
  expect_equal(plot$scales$get_scales("x")$limits, range(outbreak$dates))
  expect_no_warning(ggplot2::ggplotGrob(plot))
})
