test_that("full intervention prevents new infections", {
  start <- as.Date("2026-01-01")
  timeline <- tidyr::expand_grid(id = c("A", "B", "C"), date = start + 0:2) |>
    dplyr::mutate(R_i = 1000)
  imported <- tibble::tibble(id = c("A", "B"), date = start)

  zero <- matrix(0, 3, 3, dimnames = list(c("A", "B", "C"), c("A", "B", "C")))

  blocked <- make_outbreak(
    timeline, imported, w = 1, dates = start + 0:2,
    intervention = \(present, date) zero + 1
  )
  expect_equal(blocked$infections$id, imported$id)
  expect_true(all(is.na(blocked$infections$source)))
})

test_that("source sampling excludes blocked routes", {
  start <- as.Date("2026-01-01")
  timeline <- tidyr::expand_grid(id = c("A", "B", "C"), date = start + 0:2) |>
    dplyr::mutate(R_i = 1000)
  imported <- tibble::tibble(id = c("A", "B"), date = start)

  zero <- matrix(0, 3, 3, dimnames = list(c("A", "B", "C"), c("A", "B", "C")))

  reduction <- zero
  reduction["A", "C"] <- 1
  outbreak <- make_outbreak(
    timeline, imported, w = 1, dates = start + 0:2,
    intervention = \(present, date) reduction
  )
  expect_equal(dplyr::filter(outbreak$infections, id == "C")$source, "B")
  expect_equal(dplyr::filter(outbreak$infections, id == "C")$date_infection, start + 1)
})

test_that("the intervention sees each day's population and infection state", {
  start <- as.Date("2026-01-01")
  timeline <- tidyr::expand_grid(id = c("A", "B", "C"), date = start + 0:2) |>
    dplyr::mutate(R_i = 1000)
  imported <- tibble::tibble(id = c("A", "B"), date = start)

  timeline <- timeline |> dplyr::filter(id == "A" | date > start)
  imported <- imported[1, ]
  seen <- list()
  intervention <- function(present, date) {
    seen[[length(seen) + 1]] <<- list(date = date, present = present)
    matrix(
      0,
      nrow = nrow(present),
      ncol = nrow(present),
      dimnames = list(present$id, present$id)
    )
  }

  outbreak <- make_outbreak(
    timeline, imported, w = 1, dates = rev(start + 0:3),
    intervention = intervention
  )
  expect_equal(purrr::map_int(seen, \(day) nrow(day$present)), c(1L, 3L, 3L, 0L))
  expect_true(all(purrr::map_lgl(seen, \(day) inherits(day$date, "Date"))))
  expect_equal(seen[[2]]$date, start + 1)
  expect_true(all(is.na(seen[[2]]$present$date_infection[-1])))
  expect_equal(seen[[3]]$present$date_infection[-1], rep(start + 1, 2))
  expect_equal(outbreak$infections$source, c(NA_character_, "A", "A"))
})

test_that("daily locations and attendance determine transmission", {
  start <- as.Date("2026-01-01")
  timeline <- tibble::tribble(
    ~id,       ~day, ~ward,
    "source",  0,    "A",
    "source",  1,    "A",
    "patient", 1,    "B",
    "staff",   1,    "B",
    "source",  2,    "A",
    "patient", 2,    "A",
    "staff",   3,    "A"
  ) |>
    dplyr::mutate(date = start + day, R_i = 1000) |>
    dplyr::select(-day)
  imported <- tibble::tibble(id = "source", date = start)
  ward_weights <- diag(2)
  dimnames(ward_weights) <- list(c("A", "B"), c("A", "B"))

  outbreak <- make_outbreak(
    timeline, imported, w = c(1, 1), dates = start + 0:4,
    mixing = list(ward = ward_weights),
    intervention = function(present, date) {
      matrix(0, nrow(present), nrow(present),
        dimnames = list(present$id, present$id)
      )
    }
  )

  # No cross-ward transmission on day 1; transfer enables infection on day 2.
  patient <- dplyr::filter(outbreak$infections, id == "patient")
  expect_equal(patient$date_infection, start + 2)
  expect_equal(patient$source, "source")
  # Staff are absent on day 2 and alone on day 3; day 4 is empty.
  expect_false("staff" %in% outbreak$infections$id)
})

test_that("outbreaks require unique person-days and an intervention function", {
  start <- as.Date("2026-01-01")
  timeline <- tibble::tibble(id = "A", date = start, R_i = 2)
  imported <- tibble::tibble(id = "A", date = start)

  expect_error(make_outbreak(timeline, imported, w = 1, dates = start,
    intervention = 0), "must be a function")
  expect_error(make_outbreak(
    dplyr::bind_rows(timeline, timeline), imported,
    w = 1, dates = start, intervention = function(present, date) 0
  ), "one row per ID and date")
})

hazard_fixture <- function() {
  present <- tibble::tibble(id = c("A", "B", "C"), lambda = c(1, 2, 0))
  weights <- matrix(
    c(1, 6, 4, 1, 1, 3, 1, 1, 1),
    nrow = 3,
    byrow = TRUE,
    dimnames = list(present$id, present$id)
  )
  zero <- matrix(0, 3, 3, dimnames = dimnames(weights))
  baseline <- matrix(
    c(0, 0.6, 0.4, 0.5, 0, 1.5, 0, 0, 0),
    nrow = 3,
    byrow = TRUE,
    dimnames = dimnames(weights)
  )
  list(present = present, weights = weights, zero = zero, baseline = baseline)
}

test_that("mixing multiplies attribute weights in person order", {
  present <- tibble::tibble(id = c("x", "y"), ward = c("B", "A"), group = c("A", "B"))
  weights <- matrix(1:4, 2, dimnames = list(c("A", "B"), c("A", "B")))

  expect_equal(mixing_matrix(present), matrix(1, 2, 2, dimnames = list(present$id, present$id)))
  expected <- matrix(c(4, 6, 6, 4), 2, dimnames = list(present$id, present$id))
  expect_equal(mixing_matrix(present, list(ward = weights, group = weights)), expected)
})

test_that("hazards normalise mixing, then apply reductions by source and recipient ID", {
  x <- hazard_fixture()
  expect_equal(transmission_hazards(x$present, x$weights, x$zero), x$baseline)

  # Combine partial and complete reductions with unequal source hazards.
  reduction <- x$zero
  reduction["A", "B"] <- 1
  reduction[, "C"] <- 0.5
  expected <- x$baseline
  expected["A", "B"] <- 0
  expected[, "C"] <- c(0.2, 0.75, 0)

  reduction <- reduction[c("C", "A", "B"), c("B", "C", "A")]
  expect_equal(transmission_hazards(x$present, x$weights, reduction), expected)
})

test_that("excluded routes and absent recipients produce no hazards", {
  x <- hazard_fixture()

  excluded <- x$weights
  excluded["A", ] <- 0
  expected <- x$baseline
  expected["A", ] <- 0
  expect_equal(transmission_hazards(x$present, excluded, x$zero), expected)

  single <- x$present[1, ]
  expect_equal(
    transmission_hazards(single, x$weights, x$zero["A", "A", drop = FALSE]),
    x$zero["A", "A", drop = FALSE]
  )
  expect_equal(
    transmission_hazards(x$present[0, ], x$weights, x$zero[0, 0]),
    x$zero[0, 0]
  )
})

test_that("intervention matrices must explicitly identify valid reductions", {
  x <- hazard_fixture()

  expect_error(transmission_hazards(x$present, x$weights, 0), "numeric matrix")
  expect_error(transmission_hazards(x$present, x$weights, x$zero[-1, ]), "numeric matrix")
  expect_error(transmission_hazards(x$present, x$weights, unname(x$zero)), "IDs present")

  wrong_ids <- x$zero
  rownames(wrong_ids) <- c("A", "B", "D")
  expect_error(transmission_hazards(x$present, x$weights, wrong_ids), "IDs present")

  for (value in c(-0.1, 1.1, NA, Inf)) {
    invalid <- x$zero
    invalid[1, 2] <- value
    expect_error(transmission_hazards(x$present, x$weights, invalid), "between 0 and 1")
  }
})

test_that("imported accepts id and date and stores the supplied cases", {
  start <- as.Date("2026-01-01")
  imported <- data.frame(id = c("B", "A"), date = start + c(1, 0))
  timeline <- tibble::tibble(id = c("A", "B"), date = start, R_i = 1)
  outbreak <- make_outbreak(
    timeline, imported = imported, w = 1, dates = as.Date(character()),
    intervention = function(present, date) stop("No days to simulate")
  )

  expect_equal(outbreak$parameters$imported, tibble::as_tibble(imported))
  expect_false("initial" %in% names(outbreak$parameters))
  expect_equal(outbreak$infections, tibble::tibble(
    id = c("A", "B"), source = NA_character_, date_infection = start + 0:1
  ))
})

test_that("imported requires a data frame with id and date", {
  start <- as.Date("2026-01-01")
  timeline <- make_timeline(1, start)
  for (invalid in list(
    list(id = "ID_1", date = start),
    data.frame(id = "ID_1", date_infection = start),
    data.frame(date = start)
  )) {
    expect_error(make_outbreak(
      timeline, imported = invalid, w = 1, dates = start,
      intervention = function(present, date) 0
    ), "`imported` must be a data frame with `id` and `date` columns", fixed = TRUE)
  }
})
