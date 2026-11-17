test_that("transmissions use the current step's date and a tidy tree", {
  outbreak <- simple_outbreak()

  expect_equal(outbreak$infections, tibble::tibble(
    from = c(NA_character_, "ID_1"), to = c("ID_1", "ID_2"),
    date = outbreak$dates
  ))
  expect_equal(offspring(outbreak), tibble::tibble(
    labels = c("ID_1", "ID_2"), offspring = c(1L, 0L)
  ))
})

test_that("one step matches simulacr and aligns directed contacts by labels", {
  t <- as.Date("2026-01-03")
  labels <- LETTERS[1:4]
  tau <- c(10, 20, 0, 0)
  C <- matrix(c(0, 0, 2, 1, 0, 0, 1, 3, rep(0, 8)), 4, byrow = TRUE,
    dimnames = list(labels, labels)
  )
  w <- simulacr::make_pmf_delay(c(0.2, 0.3, 0.5))
  model <- make_population(
    make_landscape(list(a = 4)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) dplyr::mutate(data, labels = .env$labels, stay = 1L, tau = .env$tau)
  )
  expected <- withr::with_seed(42, simulacr::simulate_outbreak_step(
    t = as.integer(t), labels = labels,
    S = c(FALSE, FALSE, TRUE, TRUE), I = c(TRUE, TRUE, FALSE, FALSE),
    date_infection = c(rep(as.integer(t), 2), -1L, -1L),
    C = C, tau = tau, w = w
  ))
  outbreak <- withr::with_seed(42, make_outbreak(model, t, w,
    imported = function(data, t) c("A", "B"),
    contacts = function(data, t) C[c(3, 1, 4, 2), c(2, 4, 1, 3)]
  ))
  secondary <- dplyr::filter(outbreak$infections, !is.na(from))

  expect_equal(secondary$from, expected$tree$from)
  expect_equal(secondary$to, expected$tree$to)
  expect_equal(as.integer(secondary$date), expected$tree$date)
  expect_equal(secondary$date, rep(t, 2))
})

test_that("new infections cannot transmit again within the same step", {
  dates <- as.Date("2026-01-01") + 0:1
  labels <- c("A", "B", "C")
  C <- matrix(0, 3, 3, dimnames = list(labels, labels))
  C["A", "B"] <- C["B", "C"] <- 1
  model <- make_population(
    make_landscape(list(a = 3)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) dplyr::mutate(data, labels = .env$labels, stay = Inf, tau = 1000)
  )
  outbreak <- make_outbreak(model, dates, w = c(1, 1),
    imported = function(data, t) if (t == dates[1]) "A" else character(),
    contacts = function(data, t) C
  )

  expect_equal(outbreak$infections$to, labels)
  expect_equal(outbreak$infections$from, c(NA_character_, "A", "B"))
  expect_equal(outbreak$infections$date, dates[c(1, 1, 2)])
})

test_that("infection probabilities use one minus exp of unnormalised total FOI", {
  withr::local_seed(123)
  model <- make_population(
    make_landscape(list(a = 1001)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) {
      dplyr::mutate(data, labels = as.character(0:1000), stay = 1L, tau = log(2))
    }
  )
  outbreak <- make_outbreak(model, as.Date("2026-01-01"), w = 1,
    imported = function(data, t) "0",
    contacts = function(data, t) get_contacts(data)
  )

  # Each of 1000 susceptible people independently has probability 0.5.
  expect_lt(abs(nrow(outbreak$infections) - 1L - 500), 6 * sqrt(250))
})

test_that("infection on the last occupied day extends stay once before departure", {
  dates <- as.Date("2026-01-01") + 0:5
  available_each_day <- numeric()
  model <- make_population(
    make_landscape(list(a = 1)),
    arrivals = function(data, t) {
      available_each_day <<- c(available_each_day, data$available)
      data$available
    },
    attributes = function(data, t) dplyr::mutate(data, stay = 2L, tau = 0),
    update = function(data, t) {
      dplyr::mutate(data,
        stay = stay + dplyr::if_else(date_infection == .env$t, 3L, 0L, missing = 0L)
      )
    }
  )
  outbreak <- make_outbreak(model, dates, w = 1,
    imported = function(data, t) if (t == dates[2]) data$labels else character(),
    contacts = function(data, t) get_contacts(data)
  )
  history <- outbreak$population

  expect_equal(available_each_day, c(1, 0, 0, 0, 0, 1))
  expect_equal(history$start, dates[c(1, 1, 1, 1, 1, 6)])
  expect_equal(history$stay, c(2, 2, 5, 5, 5, 2))
  expect_equal(dplyr::n_distinct(history$labels), 2L)
  expect_equal(outbreak$infections$date, dates[2])
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
  outbreak <- make_outbreak(model, dates, w = c(1, 1, 1),
    imported = function(data, t) if (t == dates[1]) "A" else character(),
    contacts = function(data, t) get_contacts(data)
  )
  history <- outbreak$population

  expect_length(seen, 3)
  expect_equal(outbreak$infections$date, dates[1:2])
  expect_equal(seen[[2]]$date_infection, dates[1:2])
  expect_equal(history$tau, c(0, 0, 1000, 0, 1000, 0))
  expect_equal(history$date_infection[history$labels == "B"], c(as.Date(NA), as.Date(NA), dates[2]))
})

test_that("patient stay extensions and returning staff keep separate capacities", {
  dates <- as.Date("2026-01-01") + 0:5
  patient_places <- staff_places <- numeric()
  patients <- make_population(
    make_landscape(list(ward = 1)),
    arrivals = function(data, t) {
      patient_places <<- c(patient_places, data$available)
      data$available
    },
    attributes = function(data, t) dplyr::mutate(data, stay = 2L, tau = 0),
    update = function(data, t) {
      dplyr::mutate(data,
        stay = stay + dplyr::if_else(date_infection == .env$t, 3L, 0L, missing = 0L)
      )
    }
  )
  staff <- make_population(
    make_landscape(list(ward = 1)),
    arrivals = function(data, t) {
      staff_places <<- c(staff_places, data$available)
      data$available
    },
    attributes = function(data, t) {
      dplyr::mutate(data, labels = "staff_1", stay = 1L, tau = 1000)
    }
  )
  outbreak <- make_outbreak(list(patients = patients, staff = staff), dates,
    w = c(0, 1),
    imported = function(data, t) if (t == dates[1]) "staff_1" else character(),
    contacts = function(data, t) get_contacts(data)
  )
  patient_history <- dplyr::filter(outbreak$population, population == "patients")
  staff_history <- dplyr::filter(outbreak$population, population == "staff")

  expect_equal(patient_places, c(1, 0, 0, 0, 0, 1))
  expect_equal(staff_places, rep(1, 6))
  expect_equal(patient_history$stay, c(2, 2, 5, 5, 5, 2))
  expect_equal(patient_history$start, dates[c(1, 1, 1, 1, 1, 6)])
  expect_equal(staff_history$stay, rep(1L, 6))
  expect_equal(staff_history$start, dates)
  expect_equal(staff_history$date_infection, rep(dates[1], 6))
  expect_equal(outbreak$infections$from, c(NA_character_, "staff_1"))
  expect_equal(outbreak$infections$date, dates[1:2])
})

test_that("returning labels retain infection history and cannot be imported twice", {
  dates <- as.Date("2026-01-01") + 0:2
  model <- make_population(
    make_landscape(list(a = 1)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) dplyr::mutate(data, labels = "staff_1", stay = 1L, tau = 0)
  )
  outbreak <- make_outbreak(model, dates, w = 1,
    imported = function(data, t) head(data$labels, 1),
    contacts = function(data, t) get_contacts(data)
  )

  expect_equal(outbreak$population$start, dates)
  expect_equal(outbreak$population$date_infection, rep(dates[1], 3))
  expect_equal(outbreak$infections, tibble::tibble(from = NA_character_, to = "staff_1", date = dates[1]))
})

test_that("new arrivals can be imported on their admission day", {
  dates <- as.Date("2026-01-01") + 0:2
  model <- make_population(
    make_landscape(list(a = 1)),
    arrivals = function(data, t) if (t == dates[2]) data$available else 0L,
    attributes = function(data, t) dplyr::mutate(data, stay = 1L, tau = 0)
  )
  outbreak <- make_outbreak(model, dates, w = 1,
    imported = function(data, t) data$labels,
    contacts = function(data, t) get_contacts(data)
  )

  expect_equal(outbreak$population$t, dates[2])
  expect_equal(outbreak$infections$date, dates[2])
  expect_equal(outbreak$infections$to, outbreak$population$labels)
})

test_that("simulacr advances on every date, including empty days", {
  dates <- as.Date("2026-01-01") + 0:2
  original_step <- simulacr::simulate_outbreak_step
  seen <- list()
  local_mocked_bindings(
    simulate_outbreak_step = function(t, labels, ...) {
      seen[[length(seen) + 1L]] <<- list(t = t, n = length(labels))
      original_step(t = t, labels = labels, ...)
    },
    .package = "simulacr"
  )
  model <- make_population(
    make_landscape(list(a = 1)),
    arrivals = function(data, t) if (t == dates[2]) data$available else 0L,
    attributes = function(data, t) dplyr::mutate(data, stay = 1L, tau = 0),
    update = function(data, t) {
      expect_equal(t, dates[2])
      data
    }
  )
  outbreak <- make_outbreak(model, dates, w = 1,
    contacts = function(data, t) {
      expect_equal(t, dates[2])
      get_contacts(data)
    },
    imported = function(data, t) character()
  )

  expect_equal(vapply(seen, `[[`, integer(1), "t"), as.integer(dates))
  expect_equal(vapply(seen, `[[`, integer(1), "n"), c(0L, 1L, 0L))
  expect_equal(outbreak$infections, tibble::tibble(
    from = character(), to = character(), date = as.Date(character())
  ))
})

test_that("identity and infection records cannot be silently rewritten", {
  date <- as.Date("2026-01-01")
  model <- make_population(
    make_landscape(list(a = 1)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) dplyr::mutate(data, labels = "A", stay = Inf, tau = 0)
  )

  expect_error(make_outbreak(model, date, w = 1, imported = function(data, t) "absent",
    contacts = function(data, t) get_contacts(data)
  ))
  expect_error(make_outbreak(list(first = model, second = model), date, w = 1,
    imported = function(data, t) character(),
    contacts = function(data, t) get_contacts(data)
  ))
  model$update <- function(data, t) dplyr::mutate(data, labels = "someone_else")
  expect_error(make_outbreak(model, date, w = 1,
    imported = function(data, t) character(),
    contacts = function(data, t) get_contacts(data)
  ))
  model$update <- function(data, t) dplyr::mutate(data, date_infection = .env$t)
  expect_error(make_outbreak(model, date, w = 1,
    imported = function(data, t) character(),
    contacts = function(data, t) get_contacts(data)
  ))
})

test_that("a daily clock and a positive PMF are required", {
  date <- as.Date("2026-01-01")
  model <- make_population(
    make_landscape(list(a = 1)),
    arrivals = function(data, t) 0L,
    attributes = function(data, t) dplyr::mutate(data, stay = 1L, tau = 0)
  )

  expect_error(make_outbreak(model, date + c(0, 2), w = 1,
    imported = function(data, t) character(),
    contacts = function(data, t) get_contacts(data)
  ))
  expect_error(make_outbreak(model, c(date, NA), w = 1,
    imported = function(data, t) character(),
    contacts = function(data, t) get_contacts(data)
  ))
  expect_error(make_outbreak(model, date, w = c(0, 0),
    imported = function(data, t) character(),
    contacts = function(data, t) get_contacts(data)
  ))
})


test_that("outbreak callbacks are required functions with consistent results", {
  model <- make_population(
    make_landscape(list(a = 1)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) dplyr::mutate(data, stay = 1L, tau = 0)
  )
  run <- function(imported, contacts) {
    make_outbreak(model, as.Date("2026-01-01"), w = 1,
      imported = imported, contacts = contacts
    )
  }
  no_imports <- function(data, t) character()
  location_contacts <- function(data, t) get_contacts(data)

  expect_error(run(contacts = location_contacts), "imported")
  expect_error(run(imported = no_imports), "contacts")
  expect_error(run(NULL, location_contacts), "is.function")
  expect_error(run(no_imports, NULL), "is.function")
  expect_error(run(function(data, t) NULL, location_contacts), "is.character")
  expect_error(run(no_imports, function(data, t) NULL), "is.matrix")
  expect_equal(nrow(run(no_imports, location_contacts)$infections), 0L)
})
