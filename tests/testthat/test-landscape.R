test_that("the vignette landscape preserves rooms and their hierarchy", {
  landscape <- list(
    H1 = list(A = c(a = 2, b = 3), B = c(a = 1, b = 4, c = 2)),
    H2 = list(A = c(a = 3, b = 5), B = c(a = 2, b = 4, c = 1))
  )
  locations <- make_landscape(landscape)
  expect_equal(locations, tibble::tibble(
    location_1 = rep(c("H1", "H2"), each = 5),
    location_2 = rep(c("A", "A", "B", "B", "B"), 2),
    location_3 = rep(c("a", "b", "a", "b", "c"), 2),
    n = c(2, 3, 1, 4, 2, 3, 5, 2, 4, 1)
  ))
  wards <- dplyr::summarise(locations, n = sum(n),
    .by = c(location_1, location_2))
  expect_equal(wards$n, c(5, 7, 8, 7))
})

test_that("zero capacity and unequal nesting depths are retained", {
  locations <- make_landscape(list(H1 = c(a = 0), H2 = list(A = c(a = 2))))
  expect_equal(locations$n, c(0, 2))
  expect_equal(locations$location_3, c(NA_character_, "a"))
  expect_named(locations, c("location_1", "location_2", "location_3", "n"))
  expect_equal(make_landscape(c(a = 2))$n, 2)
})

test_that("locations require unique sibling names and valid capacities", {
  expect_error(make_landscape(list(c(a = 2))))
  expect_error(make_landscape(list(H1 = c(a = 2), H1 = c(a = 3))))
  expect_error(make_landscape(c(a = 2, a = 3)))
  expect_error(make_landscape(list()))
  for (n in c(-1, NA_real_, Inf, 0.5)) {
    expect_error(make_landscape(list(H1 = c(a = n))))
  }
})
