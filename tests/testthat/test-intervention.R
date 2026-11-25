test_that("interventions match weighting sampled contacts after generation", {
  dates <- as.Date("2026-01-01") + 0:3
  labels <- LETTERS[1:4]
  model <- make_population(
    make_landscape(list(a = 4)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) {
      dplyr::mutate(data, labels = .env$labels, stay = Inf, tau = 0.8)
    }
  )
  run <- function(contacts, intervention = NULL) {
    run_outbreak(model, dates, w = c(1, 1, 1),
      imported = function(data, t) if (t == dates[1]) "A" else character(),
      contacts = contacts, intervention = intervention
    )
  }
  contacts <- function(data, t) sample_contacts(get_contacts(data) * 3)
  E <- matrix(c(1, 0, 0.5, 2, 1, 1, 0, 1, 0.25, 1, 1, 0, 1, 2, 1, 1),
    4, byrow = TRUE, dimnames = list(labels, labels))

  for (effect in list(E, E * 0)) {
    set.seed(123)
    expected <- run(function(data, t) contacts(data, t) * effect)
    set.seed(123)
    actual <- run(contacts, function(data, t) effect[c(3, 1, 4, 2), c(2, 4, 1, 3)])
    expect_equal(actual$infections, expected$infections)
    expect_equal(actual$population, expected$population)
  }
  set.seed(123)
  baseline <- run(contacts)
  set.seed(123)
  neutral <- run(contacts, function(data, t) get_intervention(data))
  expect_equal(neutral$infections, baseline$infections)
})

test_that("dated interventions block the intended direction and see imports", {
  dates <- as.Date("2026-01-01") + 0:1
  model <- make_population(
    make_landscape(list(a = 3)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) {
      dplyr::mutate(data, labels = c("A", "B", "C"), stay = Inf, tau = 1000)
    }
  )
  seen <- list()
  intervention <- function(data, t) {
    seen[[length(seen) + 1L]] <<- list(data = data, t = t)
    E <- get_intervention(data)
    E[, "C"] <- 0
    if (t == dates[1]) E["A", "B"] <- 0
    E[c(3, 1, 2), c(2, 3, 1)]
  }
  outbreak <- run_outbreak(model, dates, w = c(1, 1),
    imported = function(data, t) if (t == dates[1]) "A" else character(),
    intervention = intervention
  )
  expect_equal(outbreak$infections, tibble::tibble(
    from = c(NA_character_, "A"), to = c("A", "B"), date = dates
  ))
  expect_equal(seen[[1]]$data$date_infection, c(dates[1], as.Date(NA), as.Date(NA)))
  expect_equal(lapply(seen, `[[`, "t"), as.list(dates))
  expect_identical(outbreak$parameters$intervention, intervention)
})

test_that("empty populations skip interventions and invalid matrices fail", {
  model <- make_population(
    make_landscape(list(a = 1)),
    arrivals = function(data, t) rep(0L, nrow(data)),
    attributes = function(data, t) dplyr::mutate(data, stay = Inf, tau = 0)
  )
  expect_no_error(run_outbreak(model, intervention = function(...) stop("empty")))
  model$arrivals <- function(data, t) data$available
  expect_error(run_outbreak(model, intervention = 1), "is.function")

  for (value in c(-1, NA, Inf)) {
    expect_error(run_outbreak(model, intervention = function(data, t) {
      get_intervention(data) * value
    }), "finite, non-negative")
  }
  expect_error(run_outbreak(model, intervention = function(data, t) matrix(1)), "names")
  expect_error(run_outbreak(model, intervention = function(data, t) {
    labels <- c(data$labels, "extra")
    matrix(1, 2, 2, dimnames = list(labels, labels))
  }), "one row and column")
})
