plot_population <- function() {
  landscape <- make_landscape(list(site = list(a = 2, b = 1, empty = 2)))
  landscape$population <- "patients"
  dates <- as.Date("2026-01-01") + 0:6
  data <- tibble::tibble(
    labels = c("a", "a", "a", "b", "b", "a", "a", "d", "d"),
    t = dates[c(1, 2, 3, 2, 3, 4, 5, 1, 2)],
    start = dates[c(1, 1, 1, 2, 2, 4, 4, 1, 1)],
    population = "patients", level_1 = "site",
    level_2 = c(rep("a", 7), "b", "b"),
    role = c("patient", "patient", "isolated", rep("patient", 6))
  )
  structure(data,
    class = c("nososim_population", class(data)),
    landscape = landscape, dates = dates
  )
}

test_that("population plots show daily attributes and retain each episode's slot", {
  population <- plot_population()
  plot <- autoplot(population, ggplot2::aes(colour = role))
  layers <- ggplot2::ggplot_build(plot)$data

  expect_equal(nrow(layers[[1]]), 5L)
  expect_equal(layers[[2]]$x, as.numeric(population$t))
  expect_equal(layers[[2]]$xend, as.numeric(population$t + 1))
  expect_identical(
    unname(plot$scales$get_scales("y")$labels),
    c(rep(" \ra\rsite", 2), " \rb\rsite", rep(" \rempty\rsite", 2))
  )
  episodes <- plot$data |>
    dplyr::summarise(slots = dplyr::n_distinct(.y), .by = c(labels, start))
  expect_true(all(episodes$slots == 1L))
  expect_equal(nrow(dplyr::distinct(plot$data, t, .y)), nrow(population))
  expect_equal(length(unique(layers[[2]]$colour[1:3])), 2L)
})

test_that("stays keep their location, row and individual colour through turnover", {
  population <- plot_population()
  # A leaves, C takes the vacated row, and A returns in another ward.
  population <- structure(tibble::tibble(
    labels = c("a", "a", rep("b", 4), "c", "c", "a", "a"),
    t = as.Date("2026-01-01") + c(0:1, 0:3, 2:3, 2:3),
    start = as.Date("2026-01-01") + c(rep(0, 6), rep(2, 4)),
    population = "patients", level_1 = "site",
    level_2 = c(rep("a", 8), "b", "b"), role = "patient"
  ), class = class(population), landscape = attr(population, "landscape"),
  dates = attr(population, "dates"))
  plot <- autoplot(population)
  stays <- ggplot2::ggplot_build(plot)$data[[2]]

  expect_equal(as.character(plot$data$.y), as.character(c(1, 1, 2, 2, 2, 2, 1, 1, 3, 3)))
  expect_equal(length(unique(stays$colour[population$labels == "a"])), 1L)
  expect_equal(length(unique(stays$colour)), 3L)
  expect_equal(nrow(dplyr::distinct(plot$data, t, .y)), nrow(population))

  outbreak <- structure(list(
    population = population,
    infections = tibble::tibble(
      from = c(NA_character_, "a"), to = c("a", "c"),
      date = as.Date("2026-01-01") + c(0, 2)
    )
  ), class = "nososim_outbreak")
  plot <- autoplot(outbreak)
  layers <- ggplot2::ggplot_build(plot)$data
  # Even after A returns elsewhere, the arrow starts at A's infection point.
  expect_equal(layers[[3]]$x, as.numeric(outbreak$infections$date[1]))
  expect_equal(layers[[3]]$xend, as.numeric(outbreak$infections$date[2]))
  expect_equal(as.numeric(layers[[3]]$y), as.numeric(layers[[2]]$y[1]))
  expect_equal(as.numeric(layers[[3]]$yend), as.numeric(layers[[2]]$y[7]))
  expect_equal(layers[[4]]$shape, c(23, 21))
})

test_that("transmission chains connect infection points at both ends", {
  outbreak <- structure(list(
    population = plot_population(),
    infections = tibble::tibble(
      from = c(NA_character_, "d", "a"), to = c("d", "a", "b"),
      date = as.Date("2026-01-01") + 0:2
    )
  ), class = "nososim_outbreak")
  layers <- ggplot2::ggplot_build(autoplot(outbreak))$data
  edges <- layers[[3]]
  points <- layers[[4]]

  expect_equal(points$x, as.numeric(outbreak$infections$date))
  expect_equal(edges$x, points$x[1:2])
  expect_equal(as.numeric(edges$y), as.numeric(points$y[1:2]))
  expect_equal(edges$xend, points$x[2:3])
  expect_equal(as.numeric(edges$yend), as.numeric(points$y[2:3]))
})

test_that("outbreak plots dispatch, allow custom colours and render sparse histories", {
  withr::local_pdf(tempfile(fileext = ".pdf"))
  outbreak <- simple_outbreak()
  plot <- autoplot(outbreak, ggplot2::aes(colour = role))
  layers <- ggplot2::ggplot_build(plot)$data
  expect_equal(length(unique(layers[[2]]$colour)), 1L)
  expect_equal(nrow(layers[[3]]), sum(!is.na(outbreak$infections$from)))
  expect_equal(nrow(layers[[4]]), nrow(outbreak$infections))
  expect_no_warning(ggplot2::ggplotGrob(plot))

  outbreak$infections <- outbreak$infections[is.na(outbreak$infections$from), ]
  expect_no_warning(ggplot2::ggplotGrob(autoplot(outbreak)))
  outbreak$infections <- outbreak$infections[0, ]
  expect_no_warning(ggplot2::ggplotGrob(autoplot(outbreak)))
  outbreak$population <- outbreak$population[0, ]
  expect_no_warning(ggplot2::ggplotGrob(autoplot(outbreak)))
})

test_that("population groups have independent capacity at matching locations", {
  population <- plot_population()
  staff <- population[1:3, ]
  staff$labels <- "staff_1"
  staff$population <- "staff"
  landscape <- attr(population, "landscape")
  staff_landscape <- landscape[1, ]
  staff_landscape$population <- "staff"
  staff_landscape$capacity <- 1L
  combined <- structure(dplyr::bind_rows(population, staff),
    landscape = dplyr::bind_rows(landscape, staff_landscape)
  )
  positions <- population_positions(combined)

  expect_equal(nrow(positions$slots), 6L)
  expect_equal(nrow(dplyr::distinct(positions$data, t, .y)), nrow(combined))
  expect_equal(length(unique(tail(positions$data$.y, 3))), 1L)
})

test_that("empty population plots retain capacity and simulation dates", {
  withr::local_pdf(tempfile(fileext = ".pdf"))
  population <- plot_population()[0, ]
  plot <- autoplot(population)
  layers <- ggplot2::ggplot_build(plot)$data

  expect_equal(nrow(layers[[1]]), 5L)
  expect_equal(nrow(layers[[2]]), 0L)
  expect_equal(plot$scales$get_scales("x")$limits, range(attr(population, "dates")))
  expect_no_warning(ggplot2::ggplotGrob(plot))
})
