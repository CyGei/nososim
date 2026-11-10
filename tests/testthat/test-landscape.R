test_that("the vignette landscape preserves rooms and their hierarchy", {
  hospital <- list(
    H1 = list(A = c(a = 2, b = 3), B = c(a = 1, b = 4, c = 2)),
    H2 = list(A = c(a = 3, b = 5), B = c(a = 2, b = 4, c = 1))
  )
  landscape <- make_landscape(hospital)
  expect_equal(landscape, tibble::tibble(
    level_1 = rep(c("H1", "H2"), each = 5),
    level_2 = rep(c("A", "A", "B", "B", "B"), 2),
    level_3 = rep(c("a", "b", "a", "b", "c"), 2),
    capacity = c(2, 3, 1, 4, 2, 3, 5, 2, 4, 1)
  ))
  wards <- dplyr::summarise(landscape, capacity = sum(capacity),
    .by = c(level_1, level_2))
  expect_equal(wards$capacity, c(5, 7, 8, 7))
})

test_that("zero capacity and unequal nesting depths are retained", {
  landscape <- make_landscape(list(H1 = c(a = 0), H2 = list(A = c(a = 2))))
  expect_equal(landscape$capacity, c(0, 2))
  expect_equal(landscape$level_3, c(NA_character_, "a"))
  expect_named(landscape, c("level_1", "level_2", "level_3", "capacity"))
  expect_equal(make_landscape(c(a = 2))$capacity, 2)
})

test_that("landscape requires unique sibling names and valid capacities", {
  expect_error(make_landscape(list(c(a = 2))))
  expect_error(make_landscape(list(H1 = c(a = 2), H1 = c(a = 3))))
  expect_error(make_landscape(c(a = 2, a = 3)))
  expect_error(make_landscape(list()))
  for (capacity in c(-1, NA_real_, Inf, 0.5)) {
    expect_error(make_landscape(list(H1 = c(a = capacity))))
  }
})
