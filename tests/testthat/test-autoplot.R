test_that("presence segments span one day", {
  timeline <- make_timeline(2, as.Date("2026-01-01") + 0:1, stay = 2)
  segments <- ggplot2::ggplot_build(autoplot(timeline))$data[[1]]

  expect_equal(segments$x, as.numeric(timeline$date))
  expect_equal(segments$xend, as.numeric(timeline$date) + 1)
  expect_equal(as.numeric(segments$y), c(2, 2, 1, 1))
})

test_that("transmission links connect source and recipient infection dates", {
  outbreak <- simple_outbreak()
  start <- outbreak$dates[1]
  layers <- ggplot2::ggplot_build(autoplot(outbreak))$data

  expect_equal(layers[[2]]$x, as.numeric(start))
  expect_equal(layers[[2]]$xend, as.numeric(start + 1))
  expect_equal(as.numeric(layers[[2]]$y), 2)
  expect_equal(as.numeric(layers[[2]]$yend), 1)
  expect_equal(layers[[3]]$x, as.numeric(outbreak$infections$date_infection))
})

plot_population <- function(landscape, counts = rep(1L, nrow(landscape))) {
  make_population(
    landscape, as.Date("2026-01-01") + 0:6,
    admissions = function(landscape, date) counts,
    individuals = function(admitted, date) dplyr::mutate(admitted,
      id = paste0(date, "_", dplyr::row_number()), start = date, end = date + 2L)
  )
}

test_that("population plots show full stays, nested labels and unused capacity", {
  landscape <- make_landscape(list(site = c(a = 2, b = 1, empty = 2)))
  population <- plot_population(landscape, c(1L, 1L, 0L))
  before <- population
  plot <- autoplot(population, ggplot2::aes(colour = id))
  layers <- ggplot2::ggplot_build(plot)$data

  expect_s3_class(population, "nososim_population")
  expect_identical(population, before)
  expect_identical(attr(population, "landscape"), landscape)
  expect_equal(nrow(layers[[1]]), sum(landscape$n))
  expect_equal(layers[[2]]$x, as.numeric(population$start))
  expect_equal(layers[[2]]$xend, as.numeric(population$end + 1))
  expect_identical(unname(plot$scales$get_scales("y")$labels),
    c(rep(" \ra\rsite", 2), " \rb\rsite", rep(" \rempty\rsite", 2)))
  expect_equal(length(levels(plot$data$.y)), sum(landscape$n))

  for (rows in split(plot$data, plot$data$.y, drop = TRUE)) {
    rows <- rows[order(rows$start), ]
    expect_true(all(head(rows$end, -1) < tail(rows$start, -1)))
  }
})

test_that("empty populations keep all capacity rows and the study dates", {
  withr::local_pdf(tempfile(fileext = ".pdf"))
  landscape <- make_landscape(list(site = c(a = 2, b = 1)))
  for (population in list(plot_population(landscape, c(0L, 0L)),
                          plot_population(landscape)[0, ])) {
    plot <- autoplot(population)
    layers <- ggplot2::ggplot_build(plot)$data
    expect_equal(nrow(layers[[1]]), 3L)
    expect_equal(nrow(layers[[2]]), 0L)
    expect_equal(plot$scales$get_scales("x")$limits, range(attr(population, "dates")))
    expect_warning(ggplot2::ggplotGrob(plot), NA)
  }
  expect_warning(ggplot2::ggplotGrob(autoplot(plot_population(make_landscape(c(a = 0))))), NA)
})

test_that("nested plots handle unequal depths and names with underscores", {
  withr::local_pdf(tempfile(fileext = ".pdf"))
  population <- plot_population(make_landscape(list(
    site_one = c(a = 1), site_two = list(area = c(a = 2))
  )))
  plot <- autoplot(population)
  expect_true(any(grepl("site_one", plot$scales$get_scales("y")$labels, fixed = TRUE)))
  expect_warning(ggplot2::ggplotGrob(plot), NA)
})

test_that("plotting detects stays that no longer fit after editing", {
  population <- plot_population(make_landscape(c(a = 1)))
  population$end[1] <- max(population$end) + 1
  expect_error(autoplot(population), "available capacity")
})
