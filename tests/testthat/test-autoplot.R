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
