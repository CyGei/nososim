test_that("infection starts the next day and offspring include zero counts", {
  outbreak <- simple_outbreak()
  expect_equal(outbreak$infections, tibble::tibble(
    id = c("ID_1", "ID_2"), source = c(NA_character_, "ID_1"),
    date_infection = outbreak$dates
  ))
  expect_equal(offspring(outbreak), tibble::tibble(
    id = c("ID_1", "ID_2"), offspring = c(1L, 0L)
  ))
})

test_that("interventions block transmission and source sampling excludes blocked routes", {
  dates <- as.Date("2026-01-01") + 0:2
  timeline <- make_timeline(3, dates, stay = 3, R = 1000)
  imported <- tibble::tibble(id = c("ID_1", "ID_2"), date = dates[1])
  ids <- unique(timeline$id)
  reduction <- matrix(0, 3, 3, dimnames = list(ids, ids))
  reduction["ID_1", "ID_3"] <- 1
  outbreak <- make_outbreak(timeline, imported, w = 1, dates = dates,
    intervention = function(present, date) reduction
  )
  expect_equal(outbreak$infections$source, c(NA_character_, NA_character_, "ID_2"))

  blocked <- make_outbreak(timeline, imported, w = 1, dates = dates,
    intervention = function(present, date) reduction * 0 + 1
  )
  expect_equal(blocked$infections$id, imported$id)
  expect_equal(blocked$parameters$imported, imported)
})

test_that("transmission uses daily attributes and attendance, including empty days", {
  dates <- as.Date("2026-01-01") + 0:4
  timeline <- tibble::tibble(
    id = c("source", "source", "patient", "staff", "source", "patient", "staff"),
    date = dates[c(1, 2, 2, 2, 3, 3, 4)],
    ward = c("A", "A", "B", "B", "A", "A", "A"), R_i = 1000
  )
  weights <- diag(2)
  dimnames(weights) <- list(c("A", "B"), c("A", "B"))
  seen <- list()
  outbreak <- make_outbreak(
    timeline, tibble::tibble(id = "source", date = dates[1]),
    w = c(1, 1), dates = rev(dates), mixing = list(ward = weights),
    intervention = function(present, date) {
      seen[[length(seen) + 1L]] <<- present
      matrix(0, nrow(present), nrow(present), dimnames = list(present$id, present$id))
    }
  )
  expect_equal(outbreak$infections$id, c("source", "patient"))
  expect_equal(outbreak$infections$date_infection, dates[c(1, 3)])
  expect_equal(vapply(seen, nrow, integer(1)), c(1L, 3L, 2L, 1L, 0L))
  expect_true(all(c("age", "lambda", "date_infection") %in% names(seen[[2]])))
})

test_that("hazards normalise mixing before applying ID-aligned reductions", {
  present <- tibble::tibble(id = c("A", "B", "C"), lambda = c(1, 2, 0))
  weights <- matrix(c(1, 6, 4, 1, 1, 3, 0, 0, 0), 3, byrow = TRUE,
    dimnames = list(present$id, present$id)
  )
  reduction <- matrix(0, 3, 3, dimnames = dimnames(weights))
  reduction["A", "B"] <- 1
  reduction[, "C"] <- 0.5
  expected <- matrix(c(0, 0, 0.2, 0.5, 0, 0.75, 0, 0, 0), 3, byrow = TRUE,
    dimnames = dimnames(weights)
  )
  expect_equal(
    transmission_hazards(present, weights, reduction[c(3, 1, 2), c(2, 3, 1)]),
    expected
  )
  reduction["A", "B"] <- 2
  expect_error(transmission_hazards(present, weights, reduction))
})
