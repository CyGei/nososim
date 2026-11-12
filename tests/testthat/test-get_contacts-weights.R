test_that("attribute weights multiply contacts by name without normalisation", {
  date <- as.Date("2026-01-02")
  population <- tibble::tibble(
    id = c("a", "b", "c"), hospital = factor(c("Geneva", "Gallen", "Geneva")),
    role = c("patient", "staff", "staff"), start = date, end = date
  )
  weights <- list(
    hospital = matrix(
      c(2, 1, 3, 1), 2, byrow = TRUE,
      dimnames = list(c("Geneva", "Gallen"), c("Geneva", "Gallen"))
    ),
    role = matrix(
      c(1, 4, 2, 3), 2, byrow = TRUE,
      dimnames = list(c("patient", "staff"), c("patient", "staff"))
    )
  )
  by <- function(i, j) i$id == "a" | j$id == "a"
  expected <- matrix(c(0, 6, 4, 4, 0, 0, 8, 0, 0), 3,
    dimnames = list(population$id, population$id)
  )
  expect_identical(get_contacts(population, date, by, weights), expected)
  expect_identical(
    get_contacts(population[1:2, ], date, by, weights), expected[1:2, 1:2]
  )

  # Earlier attributes and matrix category order do not affect today's weights.
  previous <- dplyr::mutate(population[1, ],
    hospital = "Gallen", start = date - 1L, end = date - 1L
  )
  reordered <- dplyr::bind_rows(previous, population[c(2, 3, 1), ])
  reversed <- lapply(weights, function(x) x[2:1, 2:1])
  expect_identical(
    get_contacts(reordered, date, by, reversed), expected[c(2, 3, 1), c(2, 3, 1)]
  )

  matched <- get_contacts(population, date, "hospital", weights)
  expect_equal(matched["a", "c"], 8)
  expect_equal(matched["c", "a"], 4)
  expect_equal(sum(matched["b", ]), 0)
  expect_error(get_contacts(population, date, by, list(role = -weights$role)))
})
