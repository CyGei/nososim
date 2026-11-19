test_that("column contacts match full locations and preserve label order", {
  data <- tibble::tibble(
    labels = letters[1:4], level_1 = c("H1", "H1", "H1", "H2"),
    level_2 = c(NA, NA, "room", NA)
  )
  expected <- matrix(0L, 4, 4, dimnames = list(data$labels, data$labels))
  expected["a", "b"] <- expected["b", "a"] <- 1L
  expect_identical(get_contacts(data), expected)
  expect_equal(sum(get_contacts(data, by = "level_2")), 6)
  expect_equal(dim(get_contacts(data[0, ])), c(0L, 0L))
  expect_error(get_contacts(data[c(1, 1), ]), "unique")
})

test_that("pairwise rules are symmetric and missing matches mean no contact", {
  data <- tibble::tibble(labels = letters[1:3], room = c("A", "A", NA))
  contacts <- get_contacts(data, by = function(i, j) i$room == j$room)
  expected <- matrix(
    c(0L, 1L, 0L, 1L, 0L, 0L, 0L, 0L, 0L), 3,
    dimnames = list(data$labels, data$labels)
  )
  expect_identical(contacts, expected)
  expect_error(get_contacts(data, by = function(i, j) i$labels < j$labels), "symmetric")

  no_pairs <- function(...) stop("No pairs")
  expect_equal(sum(get_contacts(data[1, ], by = no_pairs)), 0L)
  expect_equal(dim(get_contacts(data[0, ], by = no_pairs)), c(0L, 0L))
})
