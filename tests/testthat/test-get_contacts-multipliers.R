test_that("attribute multipliers multiply contacts by name without normalisation", {
  data <- tibble::tibble(
    labels = c("a", "b", "c"), hospital = factor(c("Geneva", "Gallen", "Geneva")),
    role = c("patient", "staff", "staff")
  )
  multipliers <- list(
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
  expect_identical(get_contacts(data, by, multipliers), expected)

  # Matrix category order does not change the named coefficients.
  reordered <- data[c(2, 3, 1), ]
  reversed <- lapply(multipliers, function(x) x[2:1, 2:1])
  expect_identical(
    get_contacts(reordered, by, reversed), expected[c(2, 3, 1), c(2, 3, 1)]
  )

  expect_error(get_contacts(data, by, list(role = -multipliers$role)))
  expect_error(
    get_contacts(data, by, list(role = multipliers$role[1, 1, drop = FALSE])),
    "cover every supplied label or category"
  )
  expect_equal(dim(get_contacts(data[0, ], by, multipliers)), c(0L, 0L))
})
