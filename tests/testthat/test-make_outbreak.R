test_that("directed contacts respect labels, infection timing and source rates", {
  dates <- as.Date("2026-01-01") + 0:4
  labels <- LETTERS[1:4]
  contacts <- matrix(0, 4, 4, dimnames = list(labels, labels))
  contacts["A", "B"] <- contacts["B", "C"] <- contacts["C", "D"] <- 1
  model <- make_population(
    make_landscape(list(a = 4)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) {
      dplyr::mutate(data, labels = .env$labels, stay = Inf, tau = c(1000, 1000, 0, 0))
    }
  )
  outbreak <- run_outbreak(model, dates, w = c(1, 0, 1),
    imported = function(data, t) if (t == dates[1]) "A" else character(),
    contacts = function(data, t) contacts[c(3, 1, 4, 2), c(2, 4, 1, 3)]
  )

  # B cannot transmit immediately or at infection age 1. C cannot transmit at all.
  expect_equal(outbreak$infections, tibble::tibble(
    from = c(NA_character_, "A", "B"), to = c("A", "B", "C"),
    date = dates[c(1, 1, 3)]
  ))
})

test_that("updates see today's infections once and affect tomorrow's contacts", {
  dates <- as.Date("2026-01-01") + 0:2
  seen <- list()
  model <- make_population(
    make_landscape(list(a = 2)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) dplyr::mutate(data, labels = c("A", "B"), stay = Inf, tau = 0),
    update = function(data, t) {
      seen[[length(seen) + 1L]] <<- data
      dplyr::mutate(data, tau = dplyr::if_else(labels == "A", 1000, 0))
    }
  )
  outbreak <- run_outbreak(model, dates, w = c(1, 1, 1),
    imported = function(data, t) if (t == dates[1]) "A" else character()
  )
  history <- outbreak$population

  expect_equal(outbreak$infections$date, dates[1:2])
  expect_equal(seen[[2]]$date_infection, dates[1:2])
  expect_equal(history$tau, c(0, 0, 1000, 0, 1000, 0))
  expect_equal(history$date_infection[history$labels == "B"], c(as.Date(NA), as.Date(NA), dates[2]))
})

test_that("patient stay extensions and returning staff keep separate capacities", {
  dates <- as.Date("2026-01-01") + 0:5
  patients <- make_population(
    make_landscape(list(ward = 1)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) dplyr::mutate(data, stay = 2L, tau = 0),
    update = function(data, t) {
      dplyr::mutate(data,
        stay = stay + dplyr::if_else(date_infection == .env$t, 3L, 0L, missing = 0L)
      )
    }
  )
  staff <- make_population(
    make_landscape(list(ward = 1)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) {
      dplyr::mutate(data, labels = "staff_1", stay = 1L, tau = 1000)
    }
  )
  outbreak <- run_outbreak(list(patients = patients, staff = staff), dates,
    w = c(0, 1),
    imported = function(data, t) intersect("staff_1", data$labels)
  )
  patient_history <- dplyr::filter(outbreak$population, population == "patients")
  staff_history <- dplyr::filter(outbreak$population, population == "staff")

  expect_equal(patient_history$stay, c(2, 2, 5, 5, 5, 2))
  expect_equal(patient_history$start, dates[c(1, 1, 1, 1, 1, 6)])
  expect_equal(staff_history$start, dates)
  expect_equal(staff_history$date_infection, rep(dates[1], 6))
  expect_equal(outbreak$infections$from, c(NA_character_, "staff_1"))
  expect_equal(outbreak$infections$date, dates[1:2])
})

test_that("arrivals after an empty day retain infection history across stays", {
  dates <- as.Date("2026-01-01") + 0:2
  model <- make_population(
    make_landscape(list(a = 1)),
    arrivals = function(data, t) if (t > dates[1]) data$available else 0L,
    attributes = function(data, t) dplyr::mutate(data, labels = "staff_1", stay = 1L, tau = 0)
  )
  outbreak <- run_outbreak(model, dates, w = 1,
    imported = function(data, t) head(data$labels, 1)
  )

  expect_equal(outbreak$population$start, dates[2:3])
  expect_equal(outbreak$population$date_infection, rep(dates[2], 2))
  expect_equal(outbreak$infections, tibble::tibble(from = NA_character_, to = "staff_1", date = dates[2]))
})

test_that("invalid simulation inputs and rewritten identities are rejected", {
  date <- as.Date("2026-01-01")
  model <- make_population(
    make_landscape(list(a = 1)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) dplyr::mutate(data, labels = "A", stay = Inf, tau = 0)
  )

  expect_error(run_outbreak(model, date + c(0, 2)))
  expect_error(run_outbreak(model, c(date, NA)))
  expect_error(run_outbreak(model, w = c(0, 0)), "positive total weight")
  expect_error(run_outbreak(model, imported = NULL), "is.function")
  expect_error(run_outbreak(model, contacts = NULL), "is.function")
  expect_error(run_outbreak(model, imported = function(data, t) "absent"), "susceptible")
  expect_error(run_outbreak(model, contacts = function(data, t) NULL), "matrices")
  expect_error(run_outbreak(list(first = model, second = model)), "unique")

  model$update <- function(data, t) dplyr::mutate(data, labels = "someone_else")
  expect_error(run_outbreak(model), "identities")
  model$update <- function(data, t) dplyr::mutate(data, date_infection = .env$t)
  expect_error(run_outbreak(model), "infection history")
})
