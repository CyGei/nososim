test_that("sampled averages approach the supplied contact rates", {
  withr::local_seed(123)
  C <- matrix(
    c(0, 2, 0.5, 1, 0, 3, 0, 0, 0), 3, byrow = TRUE,
    dimnames = list(letters[1:3], letters[1:3])
  )
  n <- 10000L
  average <- Reduce(`+`, replicate(n, sample_contacts(C), simplify = FALSE)) / n

  expect_true(all(abs(average - C) <= 5 * sqrt(C / n)))
})
