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
  seen <- list()
  population <- make_population(
    landscape,
    arrivals = function(data, t) {
      expect_equal(data[names(landscape)], landscape)
      expect_equal(t, dates[length(seen) + 1L])
      seen[[length(seen) + 1L]] <<- data$available
      data$available
    },
    attributes = function(data, t) dplyr::mutate(data, age = 40L, tau = 0)
  )
  history <- make_outbreak(population, dates, w = 1,
    imported = function(data, t) character(),
    contacts = function(data, t) get_contacts(data)
  )$population
  arrivals <- dplyr::distinct(history, labels, level_1, start)

  expect_equal(seen, list(c(1, 2), c(1, 0), c(1, 2), c(1, 0)))
  expect_equal(arrivals$start[arrivals$level_1 == "a"], dates)
  expect_equal(arrivals$start[arrivals$level_1 == "b"], rep(dates[c(1, 3)], each = 2))
  expect_equal(dplyr::count(history, t)$n, rep(3L, 4))
  expect_equal(history$age, rep(40L, 12))
  expect_equal(dplyr::n_distinct(history$labels), 8L)
  expect_s3_class(history, "nososim_population")
  expect_equal(attr(history, "dates"), dates)
  expect_equal(population$landscape, landscape)
  expect_false("available" %in% names(history))
})

test_that("empty days skip individual generation and preserve typed outputs", {
  dates <- as.Date("2026-01-01") + 0:1
  population <- make_population(
    make_landscape(list(a = 0, b = 2)),
    arrivals = function(data, t) c(0L, 0L),
    attributes = function(...) stop("No arrivals")
  )
  outbreak <- make_outbreak(population, dates, w = 1,
    imported = function(data, t) character(),
    contacts = function(data, t) get_contacts(data)
  )

  expect_equal(nrow(outbreak$population), 0L)
  expect_equal(nrow(outbreak$infections), 0L)
  expect_type(outbreak$population$labels, "character")
  expect_type(outbreak$infections$from, "character")
  expect_type(outbreak$infections$to, "character")
  expect_s3_class(outbreak$population$t, "Date")
  expect_s3_class(outbreak$infections$date, "Date")
  expect_equal(attr(outbreak$population, "dates"), dates)
})

test_that("population groups have independent capacity and globally unique labels", {
  dates <- as.Date("2026-01-01") + 0:1
  model <- make_population(
    make_landscape(list(a = 1)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) dplyr::mutate(data, stay = Inf, tau = 0)
  )
  history <- make_outbreak(list(patients = model, staff = model), dates, w = 1,
    imported = function(data, t) character(),
    contacts = function(data, t) get_contacts(data)
  )$population

  expect_equal(dplyr::count(history, population, t)$n, rep(1L, 4))
  expect_setequal(history$population, c("patients", "staff"))
  expect_equal(dplyr::n_distinct(history$labels), 2L)
})

test_that("generated labels cannot collide with previously supplied labels", {
  dates <- as.Date("2026-01-01") + 0:1
  supplied <- make_population(
    make_landscape(list(a = 1)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) {
      dplyr::mutate(data, labels = "person_2", stay = 1L, tau = 0)
    }
  )
  generated <- make_population(
    make_landscape(list(a = 1)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) dplyr::mutate(data, stay = 1L, tau = 0)
  )
  history <- make_outbreak(list(supplied = supplied, generated = generated), dates, w = 1,
    imported = function(data, t) character(),
    contacts = function(data, t) get_contacts(data)
  )$population

  expect_equal(nrow(dplyr::distinct(history, labels, t)), 4L)
  expect_equal(dplyr::n_distinct(history$labels), 3L)
  expect_false(any(history$labels[history$population == "generated"] == "person_2"))
})

test_that("callbacks respect capacity, allocated rows and valid attributes", {
  run <- function(arrivals = function(data, t) data$available,
                  attributes = function(data, t) dplyr::mutate(data, stay = 1L, tau = 0)) {
    model <- make_population(make_landscape(list(a = 1)), arrivals, attributes)
    make_outbreak(model, as.Date("2026-01-01"), w = 1,
      imported = function(data, t) character(),
      contacts = function(data, t) get_contacts(data)
    )
  }

  expect_error(run(arrivals = function(...) 2L))
  expect_error(run(arrivals = function(...) 0.5))
  expect_error(run(attributes = function(data, t) data[0, ]))
  expect_error(run(attributes = function(data, t) {
    dplyr::mutate(data, level_1 = "elsewhere", stay = 1L, tau = 0)
  }))
  expect_error(run(attributes = function(data, t) dplyr::mutate(data, stay = 0L, tau = 0)))
  expect_error(run(attributes = function(data, t) dplyr::mutate(data, stay = 1L, tau = -1)))
})
