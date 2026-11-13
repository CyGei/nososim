test_that("infection starts the next day and offspring include zero counts", {
  outbreak <- simple_outbreak()
  expect_equal(outbreak$infections, tibble::tibble(
    id = c("ID_1", "ID_2"), source = c(NA_character_, "ID_1"),
    date_infection = outbreak$dates
  ))
  expect_equal(offspring(outbreak), tibble::tibble(
    id = c("ID_1", "ID_2"), offspring = c(1L, 0L)
  ))
  expect_equal(outbreak$reproduction$R_i, c(1000, 1000))
})

test_that("directed FOI uses unnormalised contacts and ID-aligned interventions", {
  date <- as.Date("2026-01-02")
  population <- tibble::tibble(
    id = c("A", "B", "C"), start = date, end = date, tau = c(1, 2, 0)
  )
  imported <- tibble::tibble(id = c("A", "B"), date_infection = date - 1L)
  contacts <- matrix(c(9, 6, 4, 1, 9, 3, 0, 0, 9), 3, byrow = TRUE,
    dimnames = list(population$id, population$id)
  )
  reduction <- matrix(0, 3, 3, dimnames = dimnames(contacts))
  reduction["A", "B"] <- 1
  reduction[, "C"] <- 0.5
  simulate <- function(scale = 1, intervention = NULL) {
    make_outbreak(population, imported, w = c(0, 2), dates = date,
      contacts = function(present, date) scale * contacts[c(3, 1, 2), c(2, 3, 1)],
      intervention = intervention
    )
  }

  expect_equal(simulate()$reproduction$R_i, c(10, 8, 0))
  expect_equal(simulate(2)$reproduction$R_i, c(20, 16, 0))
  controlled <- simulate(intervention = function(present, date) {
    reduction[c(2, 3, 1), c(3, 1, 2)]
  })
  expect_equal(controlled$reproduction$R_i, c(2, 5, 0))
  blocked <- simulate(intervention = function(present, date) reduction * 0 + 1)
  expect_equal(blocked$infections$id, imported$id)
})

test_that("source assignment excludes blocked routes", {
  dates <- as.Date("2026-01-01") + 0:2
  population <- tibble::tibble(
    id = c("A", "B", "C"), level_1 = "hospital",
    start = dates[1], end = dates[3], tau = 1000
  )
  outbreak <- make_outbreak(
    population, tibble::tibble(id = c("A", "B"), date_infection = dates[1]),
    w = 1, dates = dates, contacts = get_contacts,
    intervention = function(present, date) {
      reduction <- matrix(0, 3, 3, dimnames = list(present$id, present$id))
      reduction["A", "C"] <- 1
      reduction
    }
  )
  expect_equal(outbreak$infections$source, c(NA_character_, NA_character_, "B"))
  expect_equal(outbreak$infections$date_infection, dates[c(1, 1, 2)])
})

test_that("infection probabilities follow one minus exp of the total FOI", {
  withr::local_seed(123)
  date <- as.Date("2026-01-01")
  population <- tibble::tibble(
    id = as.character(0:1000), level_1 = "hospital",
    start = date, end = date, tau = log(2)
  )
  outbreak <- make_outbreak(
    population, tibble::tibble(id = "0", date_infection = date - 1L),
    w = c(0, 1), dates = date, contacts = get_contacts
  )
  # Each of 1000 susceptible people independently has probability 0.5.
  expect_lt(abs(nrow(outbreak$infections) - 1L - 500), 6 * sqrt(250))
})

test_that("infection persists across shifts and imports occur on their dates", {
  dates <- as.Date("2026-01-01") + 0:4
  population <- tibble::tibble(
    id = c("A", "A", "B", "C"), level_1 = "hospital", age = 40L,
    start = dates[c(1, 3, 1, 2)], end = dates[c(1, 3, 4, 2)]
  )
  seen <- list()
  outbreak <- make_outbreak(
    population, tibble::tibble(id = c("A", "B", "C"), date_infection = dates[c(1, 5, 2)]),
    w = c(0.5, 0, 0.5), dates = rev(dates),
    tau = function(present, date) rep(if (date == dates[3]) 1000 else 0, nrow(present)),
    contacts = function(present, date) {
      seen[[length(seen) + 1L]] <<- present
      get_contacts(present, date)
    }
  )
  expect_equal(outbreak$infections, tibble::tibble(
    id = c("A", "C", "B"), source = c(NA_character_, NA_character_, "A"),
    date_infection = dates[c(1, 2, 4)]
  ))
  expect_true(is.na(seen[[2]]$date_infection[seen[[2]]$id == "B"]))
  expect_equal(seen[[3]]$infectiousness, c(500, 0))
  expect_equal(seen[[3]]$infection_age, c(2L, NA_integer_))
  expect_equal(seen[[3]]$age, c(40L, 40L))
  expect_equal(vapply(seen, nrow, integer(1)), c(2L, 2L, 2L, 1L, 0L))
})


test_that("one step matches simulacr including its PMF and next-day dates", {
  date <- as.Date("2026-01-03")
  population <- tibble::tibble(
    id = c("A", "B", "C", "D"), start = date, end = date,
    tau = c(10, 20, 0, 0)
  )
  imported <- tibble::tibble(id = c("A", "B"), date_infection = date - 1:2)
  C <- matrix(c(0, 0, 2, 1, 0, 0, 1, 3, rep(0, 8)), 4, byrow = TRUE,
    dimnames = list(population$id, population$id)
  )
  E <- C * 0
  E["A", "C"] <- 0.5
  w <- simulacr::make_pmf_delay(c(0.2, 0.3, 0.5))
  expected <- withr::with_seed(42, simulacr::simulate_outbreak_step(
    t = as.integer(date), labels = population$id,
    S = c(FALSE, FALSE, TRUE, TRUE), I = c(TRUE, TRUE, FALSE, FALSE),
    date_infection = c(as.integer(imported$date_infection), -1L, -1L),
    C = C * (1 - E), tau = population$tau, w = w
  ))
  outbreak <- withr::with_seed(42, make_outbreak(
    population, imported, w = w, dates = date,
    contacts = function(present, date) C,
    intervention = function(present, date) E
  ))
  new <- dplyr::filter(outbreak$infections, !is.na(source))
  expect_equal(new$id, expected$tree$to)
  expect_equal(new$source, expected$tree$from)
  expect_equal(as.integer(new$date_infection), expected$tree$date)
  expect_equal(new$date_infection, rep(date + 1L, 2))
  expect_equal(outbreak$parameters$w(0:2), c(0.2, 0.3, 0.5))
})
