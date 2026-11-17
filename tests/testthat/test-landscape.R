test_that("landscapes preserve hierarchy, input order and zero capacities", {
  landscape <- make_landscape(list(
    H1 = list(a = 0), H2 = list(A = list(a = 2, b = 3))
  ))
  expect_equal(landscape, tibble::tibble(
    level_1 = c("H1", "H2", "H2"),
    level_2 = c("a", "A", "A"),
    level_3 = c(NA_character_, "a", "b"),
    capacity = c(0, 2, 3)
  ))
  expect_equal(make_landscape(list(a = 2)), tibble::tibble(level_1 = "a", capacity = 2))
})

test_that("landscapes require named lists and scalar leaves", {
  expect_error(make_landscape(c(a = 2)))
  expect_error(make_landscape(list(2)))
  expect_error(make_landscape(list(A = list(2))))
  expect_error(make_landscape(list()))
  expect_error(make_landscape(list(A = numeric())))
  expect_error(make_landscape(list(A = c(a = 2, b = 3))))
})
