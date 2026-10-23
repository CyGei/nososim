test_that("daily construction preserves person attributes and stay boundaries", {
  start <- as.Date("2026-01-01")

  withr::local_seed(123)
  timeline <- make_timeline(
    3, start + 0:5, attributes = list(
      ward = c(A = 1, B = 0, C = 0),
      role = c(patient = 0, visitor = 1)
    ),
    admission_delay = 3, stay = 2, R = c(0.5, 3, 8)
  )
  expect_equal(nrow(timeline), 6L)
  expect_true(all(timeline$ward == "A" & timeline$role == "visitor"))
  people <- timeline |> dplyr::group_by(id) |>
    dplyr::summarise(n_R = dplyr::n_distinct(R_i), first = min(date), last = max(date))
  expect_true(all(people$n_R == 1))
  expect_true(all(timeline$R_i %in% c(0.5, 3, 8)))
  expect_true(all(people$first == start + 3 & people$last == start + 4))
  expect_equal(anyDuplicated(timeline[c("id", "date")]), 0L)
})

test_that("construction clips attendance to requested dates", {
  start <- as.Date("2026-01-01")

  timeline <- make_timeline(
    1, start + c(0, 2, 4),
    admission_delay = -1, stay = 5
  )
  expect_equal(timeline$date, start + c(0, 2))
  expect_equal(names(timeline), c("id", "date", "R_i"))
  expect_equal(nrow(make_timeline(
    1, start, admission_delay = 1
  )), 0L)
  expect_error(make_timeline(
    1, c(start, start)
  ))
})

test_that("a single R value is assigned exactly, including zero", {
  start <- as.Date("2026-01-01")

  for (value in c(0, 2.5)) {
    timeline <- make_timeline(
      2, start, R = value
    )
    expect_equal(timeline$R_i, rep(value, 2))
  }
})

test_that("attribute edits respect IDs, both boundaries and other columns", {
  start <- as.Date("2026-01-01")
  timeline <- tidyr::expand_grid(id = c("ID_1", "ID_2", "ID_3"), date = start + 0:4) |>
    dplyr::mutate(ward = "A", service = "general", R_i = 2)

  updated <- set_attribute(
    timeline, id = c("ID_1", "ID_2"), from = start + 1, to = start + 3,
    attributes = list(ward = "B", service = "ICU")
  )
  expect_equal(dplyr::filter(updated, id == "ID_1")$ward, c("A", "B", "B", "A", "A"))
  expect_equal(dplyr::filter(updated, id == "ID_2")$service,
               c("general", "ICU", "ICU", "general", "general"))
  expect_equal(dplyr::filter(updated, id == "ID_3"), dplyr::filter(timeline, id == "ID_3"))
  expect_equal(dplyr::select(updated, id, date, R_i), dplyr::select(timeline, id, date, R_i))
})

test_that("open-ended and later edits only change existing matching rows", {
  start <- as.Date("2026-01-01")
  timeline <- tidyr::expand_grid(id = c("ID_1", "ID_2", "ID_3"), date = start + 0:4) |>
    dplyr::mutate(ward = "A", service = "general", R_i = 2)

  updated <- timeline |>
    set_attribute("ID_1", start + 1, attributes = list(ward = "B")) |>
    set_attribute("ID_1", start + 3, attributes = list(ward = "C"))
  expect_equal(dplyr::filter(updated, id == "ID_1")$ward, c("A", "B", "B", "C", "C"))
  expect_equal(set_attribute(timeline, "absent", start, attributes = list(ward = "B")), timeline)
})

test_that("weekly schedules remove only selected individuals' off-days", {
  monday <- as.Date("2026-01-05")
  timeline <- tidyr::expand_grid(id = c("ID_1", "ID_2", "ID_3"), date = monday + 0:13) |>
    dplyr::mutate(ward = "A", R_i = 2)

  scheduled <- set_schedule(timeline, id = c("ID_1", "ID_2"))
  expected <- monday + c(0:4, 7:11)
  expect_equal(dplyr::filter(scheduled, id == "ID_1")$date, expected)
  expect_equal(dplyr::filter(scheduled, id == "ID_2")$date, expected)
  expect_equal(dplyr::filter(scheduled, id == "ID_3"), dplyr::filter(timeline, id == "ID_3"))
  weekends <- set_schedule(timeline, "ID_1", weekdays = 6:7)
  expect_equal(dplyr::filter(weekends, id == "ID_1")$date, monday + c(5, 6, 12, 13))
})

test_that("schedules never add attendance", {
  monday <- as.Date("2026-01-05")
  timeline <- tidyr::expand_grid(id = c("ID_1", "ID_2", "ID_3"), date = monday + 0:13) |>
    dplyr::mutate(ward = "A", R_i = 2)

  scheduled <- set_schedule(timeline, "ID_1")
  expect_equal(set_schedule(scheduled, "ID_1", weekdays = 1:7), scheduled)
  expect_equal(set_schedule(timeline, "unknown"), timeline)
  expect_equal(set_schedule(timeline, character()), timeline)
})

test_that("timelines retain their class through attendance and attribute edits", {
  dates <- as.Date("2026-01-05") + 0:6
  timeline <- make_timeline(2, dates, stay = 7,
    attributes = list(ward = c(A = 1))
  )
  updated <- timeline |>
    set_attribute("ID_1", dates[2], attributes = list(ward = "B")) |>
    set_schedule("ID_1")

  expect_s3_class(updated, "nososim_timeline")
})
