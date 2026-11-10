test_that("only admitted people are generated and capacity is reused after end", {
  landscape <- make_landscape(list(site = c(a = 1, b = 2)))
  dates <- as.Date("2026-01-01") + 0:6
  drawn <- integer()
  population <- make_population(
    landscape = landscape, dates = rev(dates),
    admissions = function(landscape, date) landscape$available,
    individuals = function(admitted, date) {
      drawn <<- c(drawn, nrow(admitted))
      dplyr::mutate(admitted, start = date,
        age = ifelse(level_2 == "a", 30L, 60L),
        end = start + ifelse(age < 50, 2L, 3L))
    }
  )
  expect_equal(sum(drawn), nrow(population))
  expect_equal(population$start[population$level_2 == "a"], dates[c(1, 4, 7)])
  expect_equal(population$start[population$level_2 == "b"], rep(dates[c(1, 5)], each = 2))
  expect_named(population, c("level_1", "level_2", "start", "age", "end"))
  expect_gt(max(population$end), max(dates))
  for (i in seq_along(dates)) {
    present <- population[population$start <= dates[i] & population$end >= dates[i], ]
    expect_true(all(tabulate(match(present$level_2, landscape$level_2), 2) <= landscape$capacity))
  }
})

test_that("one-day stays include end and free capacity the next day", {
  dates <- as.Date("2026-01-01") + 0:2
  population <- make_population(
    make_landscape(c(A = 1)), dates,
    admissions = function(landscape, date) landscape$available,
    individuals = function(admitted, date) {
      dplyr::mutate(admitted, start = date, end = date)
    }
  )
  expect_equal(population$start, dates)
  expect_equal(population$end, dates)
  segments <- ggplot2::ggplot_build(ggplot2::autoplot(population))$data[[2]]
  expect_equal(segments$xend - segments$x, rep(1, 3))
})

test_that("admission rules use dates and user-defined location parameters", {
  landscape <- dplyr::mutate(make_landscape(c(a = 1, b = 2)), zone = c("north", "south"))
  dates <- as.Date("2026-01-02") + 0:4
  seen <- as.Date(character())
  admissions <- function(landscape, date) {
    seen <<- c(seen, date)
    as.integer(landscape$zone == "north" & as.integer(format(date, "%u")) <= 5L & landscape$available > 0)
  }
  population <- make_population(landscape, dates, admissions,
    function(admitted, date) dplyr::mutate(admitted, start = date, end = date + 1L))
  expect_equal(seen, dates)
  expect_equal(population$start, dates[c(1, 4)])
  expect_true(all(population$zone == "north"))
})

test_that("individuals control their output columns and random attributes", {
  landscape <- dplyr::mutate(make_landscape(c(a = 2)), parameter = 10)
  generate <- function() make_population(
    landscape, as.Date("2026-01-01") + 0:2,
    function(landscape, date) as.integer(landscape$available > 0),
    function(admitted, date) dplyr::transmute(admitted,
      level_1, start = date, end = date + 1L,
      age = sample(18:90, dplyr::n(), replace = TRUE),
      birthday = date - age * 365, tags = rep(list(c("a", "b")), dplyr::n()))
  )
  a <- withr::with_seed(42, generate())
  expect_identical(a, withr::with_seed(42, generate()))
  expect_named(a, c("level_1", "start", "end", "age", "birthday", "tags"))
  expect_s3_class(a$birthday, "Date")
  expect_equal(a$tags, rep(list(c("a", "b")), nrow(a)))
})

test_that("no individual function is called without an available admission", {
  dates <- as.Date("2026-01-01") + 0:2
  for (n in c(0, 2)) {
    population <- make_population(make_landscape(c(a = n)), dates,
      function(landscape, date) rep(0L, nrow(landscape)),
      function(...) stop("No individuals should be drawn"))
    expect_equal(nrow(population), 0L)
  }
})

test_that("counts and generated periods must respect the allocation", {
  landscape <- make_landscape(c(a = 1))
  dates <- as.Date("2026-01-01") + 0:1
  admissions <- function(landscape, date) as.integer(landscape$available > 0)
  individuals <- function(admitted, date) dplyr::mutate(admitted, start = date, end = date + 1L)
  for (value in list(-1L, 0.5, NA_real_, Inf, 2L, numeric(), matrix(1))) {
    expect_error(make_population(landscape, dates, function(landscape, date) value, individuals))
  }
  for (invalid in list(
    function(admitted, date) dplyr::mutate(admitted, start = date, end = date - 1L),
    function(admitted, date) dplyr::mutate(admitted, start = date + 1L, end = date + 2L),
    function(admitted, date) dplyr::mutate(admitted, level_1 = "elsewhere", start = date, end = date + 1L),
    function(admitted, date) admitted[0, ]
  )) {
    expect_error(make_population(landscape, dates, admissions, invalid))
  }
  expect_error(make_population(landscape, dates[c(1, 1)], admissions, individuals))
  expect_error(make_population(landscape, dates + c(0, 1), admissions, individuals))
  expect_error(make_population(dplyr::mutate(landscape, capacity = -1), dates, admissions, individuals))
})

test_that("daily availability tracks occupancy without changing the landscape", {
  landscape <- dplyr::mutate(
    make_landscape(c(a = 2, b = 0)), filling_rate = c(0.5, 0.2))
  original <- landscape
  dates <- as.Date("2026-01-01") + 0:3
  seen <- list()
  population <- make_population(
    landscape, dates,
    admissions = function(landscape, date) {
      seen[[length(seen) + 1L]] <<- landscape
      landscape$available
    },
    individuals = function(admitted, date) {
      expect_false("available" %in% names(admitted))
      dplyr::mutate(admitted, start = date, end = date + 1L)
    }
  )
  expect_equal(lapply(seen, function(x) x$available),
    list(c(2, 0), c(0, 0), c(2, 0), c(0, 0)))
  expect_true(all(vapply(seen, function(x) identical(x$capacity, original$capacity),
    logical(1))))
  expect_equal(landscape, original)
  expect_equal(attr(population, "landscape"), original)
  expect_equal(population$start, rep(dates[c(1, 3)], each = 2))
})

test_that("binomial admissions use free beds and per-bed filling rates", {
  landscape <- dplyr::mutate(
    make_landscape(c(a = 20, b = 10, closed = 0)),
    filling_rate = c(0.5, 0, 1))
  dates <- as.Date("2026-01-01") + 0:3
  expected <- withr::with_seed(42, {
    free <- landscape$capacity
    draws <- list()
    for (i in seq_along(dates)) {
      draws[[i]] <- stats::rbinom(nrow(landscape), free,
        1 - exp(-landscape$filling_rate))
      free <- free - draws[[i]]
    }
    draws
  })
  observed <- list()
  population <- withr::with_seed(42, make_population(
    landscape, dates,
    admissions = function(landscape, date) {
      counts <- stats::rbinom(nrow(landscape), landscape$available,
        1 - exp(-landscape$filling_rate))
      observed[[length(observed) + 1L]] <<- counts
      counts
    },
    individuals = function(admitted, date) {
      dplyr::mutate(admitted, start = date, end = max(dates))
    }
  ))
  expect_equal(observed, expected)
  expect_equal(nrow(population), sum(unlist(expected)))
  expect_true(all(population$level_1 == "a"))
})
