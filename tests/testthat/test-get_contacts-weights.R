contact_weight_fixture <- function() {
  date <- as.Date("2026-01-02")
  population <- tibble::tibble(
    id = c("a", "b", "c"),
    hospital = factor(c("Geneva", "Gallen", "Geneva")),
    role = c("patient", "staff", "staff"), start = date, end = date
  )
  hospital <- matrix(c(2, 1, 3, 1), 2, byrow = TRUE,
    dimnames = list(c("Geneva", "Gallen"), c("Geneva", "Gallen")))
  role <- matrix(c(1, 4, 2, 3), 2, byrow = TRUE,
    dimnames = list(c("patient", "staff"), c("patient", "staff")))
  list(date = date, population = population,
       by = function(i, j) i$id == "a" | j$id == "a",
       weights = list(hospital = hospital, role = role))
}

test_that("optional weights multiply pairwise contacts and retain direction", {
  x <- contact_weight_fixture()
  before <- x$population
  result <- get_contacts(x$population, x$date, x$by, weights = x$weights)
  expected <- matrix(c(0, 6, 4, 4, 0, 0, 8, 0, 0), 3,
    dimnames = list(x$population$id, x$population$id))
  expect_identical(result, expected)
  expect_false(isSymmetric(result))
  expect_identical(x$population, before)
  binary <- get_contacts(x$population, x$date, x$by)
  expect_identical(get_contacts(x$population, x$date, x$by, weights = NULL), binary)
  expect_identical(get_contacts(x$population, x$date, x$by, weights = list()), binary)
  expect_true(all(result[binary == 0] == 0))
  expect_true(all(diag(result) == 0))
})

test_that("weights also work with column matching", {
  x <- contact_weight_fixture()
  result <- get_contacts(x$population, x$date, by = "hospital", weights = x$weights)
  expect_equal(result["a", "c"], 8)
  expect_equal(result["c", "a"], 4)
  expect_equal(sum(result["b", ]), 0)
  expect_equal(sum(result[, "b"]), 0)
})

test_that("daily attributes and category names determine weighting", {
  x <- contact_weight_fixture()
  expected <- get_contacts(x$population, x$date, x$by, weights = x$weights)
  previous <- x$population[1, ]
  previous$hospital <- factor("Gallen")
  previous$start <- previous$end <- x$date - 1L
  future <- x$population[2, ]
  future$id <- "future"
  future$start <- future$end <- x$date + 1L
  population <- dplyr::bind_rows(previous, x$population[c(2, 3, 1), ], future)
  weights <- lapply(x$weights, function(w) w[2:1, 2:1])
  result <- get_contacts(population, x$date, x$by, weights = weights)
  ids <- c("b", "c", "a")
  expect_identical(result, expected[ids, ids])
  # Per-contact intensities do not depend on the number of recipients present.
  subset <- get_contacts(x$population[1:2, ], x$date, x$by, weights = x$weights)
  expect_identical(subset, expected[1:2, 1:2])
})

test_that("weighted contacts handle empty and single-person populations", {
  x <- contact_weight_fixture()
  for (rows in list(integer(), 1L)) {
    population <- x$population[rows, ]
    result <- get_contacts(population, x$date,
      by = function(i, j) stop("No pairs to compare"), weights = x$weights)
    expect_equal(dim(result), rep(length(rows), 2))
    expect_equal(sum(result), 0)
  }
  empty <- get_contacts(x$population, x$date + 1L, by = "hospital", weights = x$weights)
  expect_equal(dim(empty), c(0L, 0L))
})

test_that("weights require named attributes and complete non-negative coefficients", {
  x <- contact_weight_fixture()
  for (weights in list(unname(x$weights), list(unknown = x$weights$hospital),
                       list(role = x$weights$role, role = x$weights$role))) {
    expect_error(get_contacts(x$population, x$date, x$by, weights = weights), "weights")
  }
  for (w in list(unname(x$weights$hospital), x$weights$hospital * -1,
                x$weights$hospital * NA_real_, x$weights$hospital * Inf,
                x$weights$hospital[1, , drop = FALSE])) {
    expect_error(get_contacts(x$population, x$date, x$by, weights = list(hospital = w)),
      "hospital")
  }
  w <- x$weights$hospital
  rownames(w) <- c("Geneva", "Geneva")
  expect_error(get_contacts(x$population, x$date, x$by, weights = list(hospital = w)),
    "unique category")
  population <- x$population
  population$hospital[1] <- NA
  expect_error(get_contacts(population, x$date, x$by, weights = x$weights), "non-missing")
  expect_error(get_contacts(x$population, x$date,
    by = function(i, j) i$id < j$id, weights = x$weights), "symmetric")
})
