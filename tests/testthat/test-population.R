test_that("only admitted people are generated and places are reused at end", {
  locations <- make_landscape(list(site = c(a = 1, b = 2)))
  dates <- as.Date("2026-01-01") + 0:6
  drawn <- integer()
  population <- make_population(
    locations, rev(dates),
    admissions = function(locations, date) rep(2L, nrow(locations)),
    individuals = function(places, date) {
      drawn <<- c(drawn, nrow(places))
      dplyr::mutate(places, start = date,
        age = ifelse(location_2 == "a", 30L, 60L),
        end = start + ifelse(age < 50, 2L, 3L))
    }
  )
  expect_equal(sum(drawn), nrow(population))
  expect_equal(population$start[population$location_2 == "a"], dates[c(1, 3, 5, 7)])
  expect_equal(population$start[population$location_2 == "b"], rep(dates[c(1, 4, 7)], each = 2))
  expect_named(population, c("location_1", "location_2", "start", "age", "end"))
  expect_gt(max(population$end), max(dates))
  for (i in seq_along(dates)) {
    present <- population[population$start <= dates[i] & population$end > dates[i], ]
    expect_true(all(tabulate(match(present$location_2, locations$location_2), 2) <= locations$n))
  }
})

test_that("admission rules use dates and user-defined location parameters", {
  locations <- dplyr::mutate(make_landscape(c(a = 1, b = 2)), zone = c("north", "south"))
  dates <- as.Date("2026-01-02") + 0:4
  seen <- as.Date(character())
  admissions <- function(locations, date) {
    seen <<- c(seen, date)
    as.integer(locations$zone == "north" & as.integer(format(date, "%u")) <= 5L)
  }
  population <- make_population(locations, dates, admissions,
    function(places, date) dplyr::mutate(places, start = date, end = date + 1L))
  expect_equal(seen, dates)
  expect_equal(population$start, dates[c(1, 4, 5)])
  expect_true(all(population$zone == "north"))
})

test_that("individuals control their output columns and random attributes", {
  locations <- dplyr::mutate(make_landscape(c(a = 2)), parameter = 10)
  generate <- function() make_population(
    locations, as.Date("2026-01-01") + 0:2,
    function(locations, date) rep(1L, nrow(locations)),
    function(places, date) dplyr::transmute(places,
      location_1, start = date, end = date + 1L,
      age = sample(18:90, dplyr::n(), replace = TRUE),
      birthday = date - age * 365, tags = rep(list(c("a", "b")), dplyr::n()))
  )
  a <- withr::with_seed(42, generate())
  expect_identical(a, withr::with_seed(42, generate()))
  expect_named(a, c("location_1", "start", "end", "age", "birthday", "tags"))
  expect_s3_class(a$birthday, "Date")
  expect_equal(a$tags, rep(list(c("a", "b")), nrow(a)))
})

test_that("no individual function is called without an available admission", {
  dates <- as.Date("2026-01-01") + 0:2
  for (n in c(0, 2)) {
    population <- make_population(make_landscape(c(a = n)), dates,
      function(locations, date) rep(if (n == 0) 3L else 0L, nrow(locations)),
      function(...) stop("No individuals should be drawn"))
    expect_equal(nrow(population), 0L)
  }
})

test_that("counts and generated periods must respect the allocation", {
  locations <- make_landscape(c(a = 1))
  dates <- as.Date("2026-01-01") + 0:1
  admissions <- function(locations, date) rep(1L, nrow(locations))
  individuals <- function(places, date) dplyr::mutate(places, start = date, end = date + 1L)
  for (value in list(-1L, 0.5, NA_real_, numeric(), matrix(1))) {
    expect_error(make_population(locations, dates, function(locations, date) value, individuals))
  }
  for (invalid in list(
    function(places, date) dplyr::mutate(places, start = date, end = date),
    function(places, date) dplyr::mutate(places, start = date + 1L, end = date + 2L),
    function(places, date) dplyr::mutate(places, location_1 = "elsewhere", start = date, end = date + 1L),
    function(places, date) places[0, ]
  )) {
    expect_error(make_population(locations, dates, admissions, invalid))
  }
  expect_error(make_population(locations, dates[c(1, 1)], admissions, individuals))
  expect_error(make_population(locations, dates + c(0, 1), admissions, individuals))
  expect_error(make_population(dplyr::mutate(locations, n = -1), dates, admissions, individuals))
})
