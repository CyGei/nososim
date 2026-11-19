test_that("edge counts use transmission-day attributes and exclude imports", {
  dates <- as.Date("2026-01-01") + 0:1
  outbreak <- list(
    population = tibble::tibble(
      labels = rep(letters[1:4], 2), t = rep(dates, each = 4),
      ward = c("A", "B", "B", "B", "B", "B", "A", "B"),
      role = rep(c("staff", "staff", "patient", "patient"), 2)
    ),
    infections = tibble::tibble(
      to = c("a", "b", "d", "c"), from = c(NA, "a", "a", "a"),
      date = c(dates[1] - 1, dates[c(1, 1, 2)])
    )
  )

  expect_equal(count_edges(outbreak, c("ward", "role"), by_date = TRUE), tibble::tibble(
    date = dates[c(1, 1, 2)], source_ward = c("A", "A", "B"),
    source_role = "staff", recipient_ward = c("B", "B", "A"),
    recipient_role = c("patient", "staff", "patient"), transmissions = 1L
  ))
  expect_equal(count_edges(outbreak, "ward"), tibble::tibble(
    source_ward = c("A", "B"), recipient_ward = c("B", "A"),
    transmissions = c(2L, 1L)
  ))

  outbreak$infections <- outbreak$infections[1, ]
  expect_equal(nrow(count_edges(outbreak, "ward")), 0L)
})

test_that("offspring includes imports and individuals with no secondary cases", {
  outbreak <- list(infections = tibble::tibble(
    from = c(NA, "a", "a", "b"), to = letters[1:4],
    date = as.Date("2026-01-01") + 0:3
  ))
  expect_equal(offspring(outbreak), tibble::tibble(
    labels = letters[1:4], offspring = c(2L, 1L, 0L, 0L)
  ))
  outbreak$infections <- outbreak$infections[0, ]
  expect_equal(nrow(offspring(outbreak)), 0L)
})
