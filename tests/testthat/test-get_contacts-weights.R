test_that("attribute weights multiply contacts by name without normalisation", {
  data <- tibble::tibble(
    labels = c("a", "b", "c"), hospital = factor(c("Geneva", "Gallen", "Geneva")),
    role = c("patient", "staff", "staff")
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
  by <- function(i, j) i$labels == "a" | j$labels == "a"
  expected <- matrix(c(0, 6, 4, 4, 0, 0, 8, 0, 0), 3,
    dimnames = list(data$labels, data$labels)
  )
  expect_identical(get_contacts(data, by, weights), expected)
  expect_identical(
    get_contacts(data[1:2, ], by, weights), expected[1:2, 1:2]
  )

  # Matrix category order does not change the named coefficients.
  reordered <- data[c(2, 3, 1), ]
  reversed <- lapply(weights, function(x) x[2:1, 2:1])
  expect_identical(
    get_contacts(reordered, by, reversed), expected[c(2, 3, 1), c(2, 3, 1)]
  )

  matched <- get_contacts(data, "hospital", weights)
  expect_equal(matched["a", "c"], 8)
  expect_equal(matched["c", "a"], 4)
  expect_equal(sum(matched["b", ]), 0)
  expect_error(get_contacts(data, by, list(role = -weights$role)))
  expect_equal(dim(get_contacts(data[0, ], by, weights)), c(0L, 0L))
})
