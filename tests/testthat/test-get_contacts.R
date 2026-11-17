test_that("column contacts use full locations and snapshot row order", {
  data <- tibble::tibble(
    labels = letters[1:3], level_1 = c("H1", "H1", "H2"),
    level_2 = NA_character_
  )
  expected <- matrix(
    c(0L, 1L, 0L, 1L, 0L, 0L, 0L, 0L, 0L), 3,
    dimnames = list(letters[1:3], letters[1:3])
  )
  expect_identical(get_contacts(data), expected)
  expect_equal(sum(get_contacts(data, by = "level_2")), 6)
  expect_equal(dim(get_contacts(data[0, ])), c(0L, 0L))
  expect_equal(unname(get_contacts(data[1, ])), matrix(0L, 1, 1))
  expect_error(get_contacts(data[c(1, 1), ]))
})

test_that("pairwise rules connect roommates and staff within their ward", {
  data <- tibble::tibble(
    labels = c("p1", "p2", "p3", "s1", "s2"), level_1 = "H1",
    level_2 = c("ICU", "ICU", "ICU", "ICU", "General"),
    level_3 = c("a", "b", "a", NA, NA),
    role = c("patient", "patient", "patient", "staff", "staff")
  )
  contacts <- get_contacts(data, by = function(i, j) {
    same_ward <- i$level_1 == j$level_1 & i$level_2 == j$level_2
    same_room <- i$level_3 == j$level_3
    either_staff <- i$role == "staff" | j$role == "staff"
    same_ward & (either_staff | same_room)
  })
  expected <- matrix(0L, 5, 5, dimnames = list(data$labels, data$labels))
  expected["p1", "p3"] <- expected["p3", "p1"] <- 1L
  expected["s1", 1:3] <- expected[1:3, "s1"] <- 1L
  expect_identical(contacts, expected)
  expect_error(get_contacts(data, by = function(i, j) i$labels < j$labels))

  for (rows in list(integer(), 1L)) {
    result <- get_contacts(data[rows, ],
      by = function(...) stop("No pairs")
    )
    expect_equal(dim(result), rep(length(rows), 2))
    expect_equal(sum(result), 0L)
  }
})
