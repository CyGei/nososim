test_that("column contacts use inclusive dates, full locations and population order", {
  date <- as.Date("2026-01-02")
  population <- tibble::tibble(
    id = letters[1:5], level_1 = c("H1", "H1", "H2", "H1", "H1"),
    level_2 = NA_character_,
    start = date + c(-1, 0, -1, 1, -2),
    end = date + c(0, 1, 0, 2, -1)
  )
  expected <- matrix(
    c(0L, 1L, 0L, 1L, 0L, 0L, 0L, 0L, 0L), 3,
    dimnames = list(letters[1:3], letters[1:3])
  )
  expect_identical(get_contacts(population, date), expected)
  expect_equal(sum(get_contacts(population, date, by = "level_2")), 6)
  expect_equal(dim(get_contacts(population, date + 10)), c(0L, 0L))
  expect_equal(unname(get_contacts(population, date + 2)), matrix(0L, 1, 1))
})

test_that("pairwise rules connect roommates and staff within their ward", {
  date <- as.Date("2026-01-01")
  population <- tibble::tibble(
    id = c("p1", "p2", "p3", "s1", "s2"), level_1 = "H1",
    level_2 = c("ICU", "ICU", "ICU", "ICU", "General"),
    level_3 = c("a", "b", "a", NA, NA),
    role = c("patient", "patient", "patient", "staff", "staff"),
    start = date, end = date
  )
  contacts <- get_contacts(population, date, by = function(i, j) {
    same_ward <- i$level_1 == j$level_1 & i$level_2 == j$level_2
    same_room <- i$level_3 == j$level_3
    either_staff <- i$role == "staff" | j$role == "staff"
    same_ward & (either_staff | same_room)
  })
  expected <- matrix(0L, 5, 5, dimnames = list(population$id, population$id))
  expected["p1", "p3"] <- expected["p3", "p1"] <- 1L
  expected["s1", 1:3] <- expected[1:3, "s1"] <- 1L
  expect_identical(contacts, expected)
  expect_error(get_contacts(population, date, by = function(i, j) i$id < j$id))

  for (rows in list(integer(), 1L)) {
    result <- get_contacts(population[rows, ], date,
      by = function(...) stop("No pairs")
    )
    expect_equal(dim(result), rep(length(rows), 2))
    expect_equal(sum(result), 0L)
  }
})
