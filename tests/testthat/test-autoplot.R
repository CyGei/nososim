test_that("population plots show inclusive stays, nested labels and unused capacity", {
  landscape <- make_landscape(list(site = c(a = 2, b = 1, empty = 2)))
  population <- make_population(landscape, as.Date("2026-01-01") + 0:6,
    admissions = function(landscape, date) pmin(c(1L, 1L, 0L), landscape$available),
    individuals = function(admitted, date) {
      dplyr::mutate(admitted,
        id = paste(date, dplyr::row_number()), start = date, end = date + 2L
      )
    }
  )
  plot <- autoplot(population, ggplot2::aes(colour = id))
  layers <- ggplot2::ggplot_build(plot)$data

  expect_equal(nrow(layers[[1]]), sum(landscape$capacity))
  expect_equal(layers[[2]]$x, as.numeric(population$start))
  expect_equal(layers[[2]]$xend, as.numeric(population$end + 1))
  expect_identical(
    unname(plot$scales$get_scales("y")$labels),
    c(rep(" \ra\rsite", 2), " \rb\rsite", rep(" \rempty\rsite", 2))
  )
  for (rows in split(plot$data, plot$data$.y, drop = TRUE)) {
    rows <- rows[order(rows$start), ]
    expect_true(all(head(rows$end, -1) < tail(rows$start, -1)))
  }
})

test_that("empty population plots retain capacity and simulation dates", {
  withr::local_pdf(tempfile(fileext = ".pdf"))
  landscape <- make_landscape(list(site = c(a = 2, b = 1)))
  dates <- as.Date("2026-01-01") + 0:6
  population <- make_population(landscape, dates,
    admissions = function(landscape, date) c(0L, 0L),
    individuals = function(...) stop("No admissions")
  )
  plot <- autoplot(population)
  layers <- ggplot2::ggplot_build(plot)$data

  expect_equal(nrow(layers[[1]]), 3L)
  expect_equal(nrow(layers[[2]]), 0L)
  expect_equal(plot$scales$get_scales("x")$limits, range(dates))
  expect_no_warning(ggplot2::ggplotGrob(plot))
})
