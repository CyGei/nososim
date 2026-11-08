test_that("contacts match full locations with inclusive stay boundaries", {
  date <- as.Date("2026-01-02")
  population <- tibble::tibble(
    id = letters[1:5],
    location_1 = c("H1", "H1", "H2", "H1", "H1"),
    location_2 = "A",
    role = c("patient", "staff", "patient", "patient", "patient"),
    start = date + c(-1, 0, -1, 1, -2),
    end = date + c(0, 1, 0, 2, -1)
  )
  contacts <- get_contacts(population, date)
  expected <- matrix(c(0L, 1L, 0L, 1L, 0L, 0L, 0L, 0L, 0L), 3,
    dimnames = list(letters[1:3], letters[1:3]))
  expect_identical(contacts, expected)
  expect_equal(sum(get_contacts(population, date, by = "location_2")), 6)
  expect_equal(sum(get_contacts(population, date,
    by = c("location_1", "location_2", "role"))), 0)
  expect_equal(dim(get_contacts(population, date + 10)), c(0L, 0L))
  expect_equal(unname(get_contacts(population, date + 2)), matrix(0L, 1, 1))
  expect_error(get_contacts(population, date, by = "unknown"))
  expect_error(get_contacts(population, date, by = character()))
  expect_error(get_contacts(population, c(date, date + 1)))
})

test_that("missing hierarchy levels match without merging different locations", {
  date <- as.Date("2026-01-01")
  population <- tibble::tibble(
    id = letters[1:3], location_1 = "A",
    location_2 = c(NA_character_, NA_character_, "B"),
    start = date, end = date
  )
  contacts <- get_contacts(population, date)
  expect_equal(contacts["a", "b"], 1L)
  expect_equal(contacts["a", "c"], 0L)
  expect_equal(unname(diag(contacts)), rep(0L, 3))
})
