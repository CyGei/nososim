test_that("timelines draw individual attributes and clip inclusive stays to dates", {
  dates <- as.Date("2026-01-01") + c(0, 2, 4, 6)
  timeline <- make_timeline(2, dates, admission_delay = 1, stay = 4, R = 2.5,
    attributes = list(ward = c(A = 1, B = 0))
  )
  expect_s3_class(timeline, "nososim_timeline")
  expect_equal(timeline$id, rep(c("ID_1", "ID_2"), each = 2))
  expect_equal(timeline$date, rep(dates[2:3], 2))
  expect_equal(timeline$R_i, rep(2.5, 4))
  expect_equal(timeline$ward, rep("A", 4))
  expect_equal(nrow(make_timeline(1, dates[1], admission_delay = 1)), 0L)
})

test_that("attribute edits and weekly schedules affect only selected people and dates", {
  dates <- as.Date("2026-01-05") + 0:6
  timeline <- make_timeline(2, dates, stay = 7, attributes = list(ward = c(A = 1)))
  updated <- timeline |>
    set_attribute("ID_1", dates[2], dates[3], attributes = list(ward = "B")) |>
    set_attribute("ID_1", dates[5], attributes = list(ward = "C")) |>
    set_schedule("ID_1")

  expect_equal(dplyr::filter(updated, id == "ID_1")$date, dates[1:5])
  expect_equal(dplyr::filter(updated, id == "ID_1")$ward, c("A", "B", "B", "A", "C"))
  expect_equal(
    dplyr::filter(updated, id == "ID_2"), dplyr::filter(timeline, id == "ID_2")
  )
  expect_s3_class(updated, "nososim_timeline")
})
