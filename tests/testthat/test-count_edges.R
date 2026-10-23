test_that("joint edge counts aggregate to single-attribute counts", {
  date <- as.Date("2026-01-01")
  outbreak <- structure(list(
    timeline = tibble::tibble(
      id = letters[1:5], date = date,
      role = c("patient", "staff", "patient", "patient", "staff"),
      ward = c("A", "B", "A", "B", "A")
    ),
    infections = tibble::tibble(
      id = letters[1:5], source = c(NA, NA, "a", "a", "b"),
      date_infection = date + c(-1, -1, 0, 0, 0)
    )
  ), class = "nososim_outbreak")

  joint <- count_edges(outbreak, by = c("role", "ward"))

  expect_equal(sum(joint$transmissions), 3L)
  for (attribute in c("role", "ward")) {
    columns <- paste0(c("source_", "recipient_"), attribute)
    aggregated <- joint |>
      dplyr::group_by(dplyr::across(dplyr::all_of(columns))) |>
      dplyr::summarise(transmissions = sum(transmissions), .groups = "drop")

    expect_equal(aggregated, count_edges(outbreak, by = attribute))
  }
})

test_that("daily counts use wards on the transmission date", {
  dates <- as.Date("2026-01-01") + 0:1
  outbreak <- structure(list(
    timeline = tibble::tibble(
      id = rep(c("a", "b", "c"), 2), date = rep(dates, each = 3),
      ward = c("A", "B", "B", "B", "B", "A")
    ),
    infections = tibble::tibble(
      id = c("a", "b", "c"), source = c(NA, "a", "a"),
      date_infection = c(dates[1] - 1, dates)
    )
  ), class = "nososim_outbreak")

  daily <- count_edges(outbreak, "ward", by_date = TRUE)
  expect_equal(daily, tibble::tibble(
    date_infection = dates, source_ward = c("A", "B"),
    recipient_ward = c("B", "A"), transmissions = c(1L, 1L)
  ))
  totals <- daily |>
    dplyr::count(source_ward, recipient_ward, wt = transmissions, name = "transmissions")
  expect_equal(totals, count_edges(outbreak, "ward"))

  outbreak$infections <- outbreak$infections[1, ]
  empty <- count_edges(outbreak, "ward", by_date = TRUE)
  expect_equal(nrow(empty), 0L)
  expect_s3_class(empty$date_infection, "Date")
})
