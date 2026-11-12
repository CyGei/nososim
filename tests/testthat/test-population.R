test_that("daily admissions use available capacity and preserve user attributes", {
  landscape <- make_landscape(c(a = 1, b = 2)) |>
    dplyr::mutate(stay = c(1L, 2L))
  dates <- as.Date("2026-01-01") + 0:3
  available <- list()
  population <- make_population(
    landscape, rev(dates),
    admissions = function(landscape, date) {
      available[[length(available) + 1L]] <<- landscape$available
      landscape$available
    },
    individuals = function(admitted, date) {
      dplyr::mutate(admitted,
        id = paste(date, dplyr::row_number()),
        start = date, end = date + stay - 1L
      )
    }
  )

  expect_equal(available, list(c(1, 2), c(1, 0), c(1, 2), c(1, 0)))
  expect_equal(population$start[population$level_1 == "a"], dates)
  expect_equal(
    population$start[population$level_1 == "b"],
    rep(dates[c(1, 3)], each = 2)
  )
  expect_equal(population$end, population$start + population$stay - 1L)
  expect_s3_class(population, "nososim_population")
  expect_equal(attr(population, "landscape"), landscape)
  expect_equal(attr(population, "dates"), dates)
})

test_that("no admissions skip individual generation and retain plot metadata", {
  landscape <- make_landscape(c(a = 0, b = 2))
  dates <- as.Date("2026-01-01") + 0:1
  population <- make_population(
    landscape, dates,
    admissions = function(landscape, date) c(0L, 0L),
    individuals = function(...) stop("No admissions")
  )
  expect_equal(nrow(population), 0L)
  expect_equal(attr(population, "landscape"), landscape)
  expect_equal(attr(population, "dates"), dates)
})

test_that("callbacks cannot exceed capacity or change allocated stays", {
  landscape <- make_landscape(c(a = 1))
  date <- as.Date("2026-01-01")
  admissions <- function(landscape, date) landscape$available
  individuals <- function(admitted, date) {
    dplyr::mutate(admitted, start = date, end = date)
  }

  expect_error(make_population(landscape, c(date, NA), admissions, individuals))
  expect_error(make_population(landscape, date, function(...) 2L, individuals))
  expect_error(make_population(landscape, date, function(...) 0.5, individuals))
  expect_error(make_population(landscape, date, admissions, function(admitted, date) {
    dplyr::mutate(admitted, level_1 = "elsewhere", start = date, end = date)
  }))
  expect_error(make_population(landscape, date, admissions, function(admitted, date) {
    dplyr::mutate(admitted, start = date, end = date - 1L)
  }))
})
