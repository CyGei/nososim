test_that("intervention multipliers combine source and recipient categories", {
  data <- tibble::tibble(
    labels = c("a", "b", "c"), ward = c("ICU", "ICU", "General"),
    vaccinated = c(FALSE, TRUE, TRUE)
  )
  wards <- c("ICU", "General")
  status <- c("FALSE", "TRUE")
  multipliers <- list(
    ward = matrix(c(0.7, 2, 0.4, 1), 2, byrow = TRUE,
      dimnames = list(wards, wards)),
    vaccinated = matrix(c(1, 0.5, 1, 0.5), 2, byrow = TRUE,
      dimnames = list(status, status))
  )
  expected <- matrix(c(0.7, 0.35, 1, 0.7, 0.35, 1, 0.4, 0.2, 0.5),
    3, byrow = TRUE, dimnames = list(data$labels, data$labels))
  expect_equal(get_intervention(data, multipliers), expected)
  expect_equal(get_intervention(data, multipliers["ward"])["a", "c"], 2)
})

test_that("neutral interventions retain all pairs including the diagonal", {
  data <- tibble::tibble(labels = c("a", "b"), level_1 = c("A", "B"))
  expected <- matrix(1, 2, 2, dimnames = list(data$labels, data$labels))
  expect_identical(get_intervention(data), expected)
  expect_identical(get_intervention(data, list()), expected)
  expect_equal(dim(get_intervention(data[0, ])), c(0L, 0L))
  expect_equal(get_intervention(data[1, ])[1, 1], 1)
})

test_that("interventions use the shared label and multiplier validation", {
  data <- tibble::tibble(labels = c("a", "b"), vaccinated = c(FALSE, TRUE))
  status <- c("FALSE", "TRUE")
  effect <- matrix(1, 2, 2, dimnames = list(status, status))
  expect_error(get_intervention(data[c(1, 1), ]), "unique")
  expect_error(get_intervention(data, list(missing = effect)), "attributes")
  expect_error(get_intervention(data, list(vaccinated = effect * NA)), "finite")
})
