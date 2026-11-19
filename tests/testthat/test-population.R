test_that("population construction only stores reusable rules", {
  population <- make_population(
    make_landscape(list(a = 1)),
    arrivals = function(...) stop("Arrivals ran during construction"),
    attributes = function(...) stop("Attributes ran during construction"),
    update = function(...) stop("Update ran during construction")
  )

  expect_s3_class(population, "nososim_population")
})

test_that("arrivals use free capacity and attributes persist through a stay", {
  landscape <- make_landscape(list(a = 1, b = 2)) |>
    dplyr::mutate(stay = c(1L, 2L))
  dates <- as.Date("2026-01-01") + 0:3
  population <- make_population(
    landscape,
    arrivals = function(data, t) data$available,
    attributes = function(data, t) {
      dplyr::mutate(data, age = 40L + as.integer(t - dates[1]), tau = 0)
    }
  )
  history <- run_outbreak(population, dates)$population
  arrivals <- dplyr::distinct(history, labels, level_1, start)

  expect_equal(arrivals$start[arrivals$level_1 == "a"], dates)
  expect_equal(arrivals$start[arrivals$level_1 == "b"], rep(dates[c(1, 3)], each = 2))
  expect_equal(history$age, 40L + as.integer(history$start - dates[1]))
  expect_identical(class(history), c("tbl_df", "tbl", "data.frame"))
})

test_that("empty days skip individual generation and preserve typed outputs", {
  dates <- as.Date("2026-01-01") + 0:1
  population <- make_population(
    make_landscape(list(a = 0, b = 2)),
    arrivals = function(data, t) c(0L, 0L),
    attributes = function(...) stop("No arrivals")
  )
  outbreak <- run_outbreak(population, dates,
    imported = function(...) stop("No occupants"),
    contacts = function(...) stop("No occupants")
  )

  expect_equal(nrow(outbreak$population), 0L)
  expect_equal(outbreak$infections, tibble::tibble(
    from = character(), to = character(), date = as.Date(character())
  ))
  expect_s3_class(outbreak$population$t, "Date")
  expect_equal(outbreak$dates, dates)
})

test_that("generated labels cannot collide with previously supplied labels", {
  dates <- as.Date("2026-01-01") + 0:1
  generated <- make_population(
    make_landscape(list(a = 1)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) dplyr::mutate(data, stay = 1L, tau = 0)
  )
  supplied <- generated
  supplied$attributes <- function(data, t) {
    dplyr::mutate(data, labels = "person_2", stay = 1L, tau = 0)
  }
  history <- run_outbreak(list(supplied = supplied, generated = generated), dates)$population

  expect_equal(nrow(dplyr::distinct(history, labels, t)), 4L)
  expect_equal(dplyr::n_distinct(history$labels), 3L)
  expect_false(any(history$labels[history$population == "generated"] == "person_2"))
})

test_that("callbacks respect capacity, allocated rows and valid attributes", {
  run <- function(arrivals = function(data, t) data$available,
                  attributes = function(data, t) dplyr::mutate(data, stay = 1L, tau = 0)) {
    model <- make_population(make_landscape(list(a = 1)), arrivals, attributes)
    run_outbreak(model)
  }

  expect_error(run(arrivals = function(...) 2L), "available capacity")
  expect_error(run(arrivals = function(...) 0.5))
  expect_error(run(attributes = function(data, t) data[0, ]), "allocated rows")
  expect_error(run(attributes = function(data, t) {
    dplyr::mutate(data, level_1 = "elsewhere", stay = 1L, tau = 0)
  }))
  expect_error(run(attributes = function(data, t) dplyr::mutate(data, stay = 0L, tau = 0)), "stay")
  expect_error(run(attributes = function(data, t) dplyr::mutate(data, stay = 1L, tau = -1)), "tau")
})
