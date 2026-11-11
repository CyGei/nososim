test_that("contacts match full locations with inclusive stay boundaries", {
  date <- as.Date("2026-01-02")
  population <- tibble::tibble(
    id = letters[1:5],
    level_1 = c("H1", "H1", "H2", "H1", "H1"),
    level_2 = "A",
    role = c("patient", "staff", "patient", "patient", "patient"),
    start = date + c(-1, 0, -1, 1, -2),
    end = date + c(0, 1, 0, 2, -1)
  )
  contacts <- get_contacts(population, date)
  expected <- matrix(c(0L, 1L, 0L, 1L, 0L, 0L, 0L, 0L, 0L), 3,
    dimnames = list(letters[1:3], letters[1:3]))
  expect_identical(contacts, expected)
  expect_equal(sum(get_contacts(population, date, by = "level_2")), 6)
  expect_equal(sum(get_contacts(population, date,
    by = c("level_1", "level_2", "role"))), 0)
  expect_equal(dim(get_contacts(population, date + 10)), c(0L, 0L))
  expect_equal(unname(get_contacts(population, date + 2)), matrix(0L, 1, 1))
  expect_error(get_contacts(population, date, by = "unknown"))
  expect_error(get_contacts(population, date, by = character()))
  expect_error(get_contacts(population, c(date, date + 1)))
})

test_that("missing hierarchy levels match without merging different locations", {
  date <- as.Date("2026-01-01")
  population <- tibble::tibble(
    id = letters[1:3], level_1 = "A",
    level_2 = c(NA_character_, NA_character_, "B"),
    start = date, end = date
  )
  contacts <- get_contacts(population, date)
  expect_equal(contacts["a", "b"], 1L)
  expect_equal(contacts["a", "c"], 0L)
  expect_equal(unname(diag(contacts)), rep(0L, 3))
})

test_that("pairwise rules connect staff across rooms within their own ward", {
  date <- as.Date("2026-01-02")
  population <- tibble::tibble(
    id = c("p1", "p2", "p3", "s1", "s2", "other_ward", "other_site", "absent"),
    level_1 = c(rep("H1", 6), "H2", "H1"),
    level_2 = c(rep("ICU", 5), "General", "ICU", "ICU"),
    level_3 = c("a", "b", "a", NA, NA, NA, NA, NA),
    role = c(rep("patient", 3), rep("staff", 5)),
    start = c(rep(date, 7), date + 1L),
    end = date + 2L
  )
  before <- population
  contacts <- get_contacts(population, date, by = function(i, j) {
    same_hospital <- i$level_1 == j$level_1
    same_ward <- i$level_2 == j$level_2
    same_room <- i$level_3 == j$level_3
    either_staff <- i$role == "staff" | j$role == "staff"
    same_hospital & same_ward & (either_staff | same_room)
  })
  expected <- matrix(0L, 7, 7, dimnames = list(population$id[1:7], population$id[1:7]))
  expected["p1", "p3"] <- expected["p3", "p1"] <- 1L
  expected[c("s1", "s2"), 1:5] <- 1L
  expected[1:5, c("s1", "s2")] <- 1L
  diag(expected) <- 0L
  expect_identical(contacts, expected)
  expect_identical(population, before)
  expect_identical(get_contacts(population, date, by = "level_1"),
    get_contacts(population, date, by = function(i, j) i$level_1 == j$level_1))
})

test_that("pairwise rules handle missing values and empty or single populations", {
  date <- as.Date("2026-01-01")
  population <- tibble::tibble(
    id = letters[1:3], group = c("A", "A", NA_character_),
    start = date, end = date
  )
  contacts <- get_contacts(population, date, by = function(i, j) i$group == j$group)
  expect_equal(contacts["a", "b"], 1L)
  expect_equal(sum(contacts["c", ]), 0L)
  expect_false(anyNA(contacts))
  for (rows in list(integer(), 1L)) {
    contacts <- get_contacts(population[rows, ], date,
      by = function(i, j) stop("No pairs to compare"))
    expect_identical(dim(contacts), rep(length(rows), 2))
    expect_equal(sum(contacts), 0L)
  }
  expect_equal(dim(get_contacts(population, date + 1L,
    by = function(i, j) stop("No people present"))), c(0L, 0L))
  expect_error(get_contacts(dplyr::mutate(population, id = "same"), date,
    by = function(i, j) i$group == j$group))
})

test_that("pairwise rules must return a symmetric logical result per pair", {
  date <- as.Date("2026-01-01")
  population <- tibble::tibble(id = letters[1:3], start = date, end = date)
  for (value in list(TRUE, logical(), c(TRUE, FALSE), rep(1, 6), matrix(TRUE, 3, 2))) {
    expect_error(get_contacts(population, date, by = function(i, j) value),
      "one logical value per pair")
  }
  expect_error(get_contacts(population, date, by = function(i, j) i$id < j$id),
    "must be symmetric")
  expect_error(get_contacts(population, date, by = 1))
})
