test_that("population summaries count people separately from person-days", {
  dates <- as.Date("2026-01-01") + 0:1
  timeline <- make_timeline(2, dates, stay = 2,
    attributes = list(ward = c(A = 1))
  ) |>
    set_attribute("ID_1", dates[2], attributes = list(ward = "B"))

  expect_equal(summary(timeline), tibble::tibble(
    attribute = c(NA, "ward", "ward"), value = c(NA, "A", "B"),
    individuals = c(2L, 2L, 1L), person_days = c(4L, 3L, 1L)
  ))
})

test_that("population summaries handle no attributes and empty attendance", {
  timeline <- make_timeline(2, as.Date("2026-01-01"), stay = 1)
  expect_equal(summary(timeline)$individuals, 2L)
  expect_equal(summary(timeline[0, ]), tibble::tibble(
    attribute = NA_character_, value = NA_character_,
    individuals = 0L, person_days = 0L
  ))
})

test_that("attribute types and missing values are summarised independently", {
  timeline <- make_timeline(2, as.Date("2026-01-01")) |>
    dplyr::mutate(ward = c("A", NA), age = c(30, 40))
  result <- summary(timeline)

  expect_equal(result$attribute, c(NA, "ward", "ward", "age", "age"))
  expect_equal(result$value, c(NA, "A", NA, "30", "40"))
  expect_equal(result$individuals, c(2L, 1L, 1L, 1L, 1L))
})

test_that("outbreak summaries distinguish initial and secondary cases", {
  outbreak <- simple_outbreak()
  start <- outbreak$dates[1]

  expect_equal(summary(outbreak), tibble::tibble(
    individuals = 2L, simulation_days = 2L, initial_cases = 1L,
    secondary_cases = 1L, total_cases = 2L,
    first_case = start, last_case = start + 1
  ))
  expect_output(print(outbreak), "<nososim_outbreak>")
})

test_that("an outbreak without cases has missing infection dates", {
  start <- as.Date("2026-01-01")
  timeline <- make_timeline(1, start)
  outbreak <- make_outbreak(
    timeline, tibble::tibble(id = character(), date_infection = as.Date(character())),
    w = 1, dates = as.Date(character()),
    intervention = function(present, date) stop("No days to simulate")
  )

  expect_equal(summary(outbreak), tibble::tibble(
    individuals = 0L, simulation_days = 0L, initial_cases = 0L,
    secondary_cases = 0L, total_cases = 0L,
    first_case = as.Date(NA), last_case = as.Date(NA)
  ))
})
