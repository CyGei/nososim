tmat_outbreak <- function() {
  dates <- as.Date("2026-01-01") + 0:1
  structure(list(
    population = tibble::tibble(
      labels = rep(letters[1:3], 2), t = rep(dates, each = 3),
      ward = factor(c("A", "B", "A", "B", "B", "A"),
        levels = c("B", "A", "unused")),
      role = rep(c("staff", "patient", "patient"), 2)
    ),
    infections = tibble::tibble(
      from = c(NA, "a", "a"), to = letters[1:3],
      date = dates[c(1, 1, 2)]
    )
  ), class = "nososim_outbreak")
}

test_that("matrices share nested ordering and count transmission-day groups", {
  plot <- plot_tmat(tmat_outbreak(), c("ward", "role"))
  expect_s3_class(plot, "ggplot")
  expect_equal(nrow(plot$data), 16L)
  expect_equal(sum(plot$data$transmissions), 2L)
  expect_equal(levels(plot$data$source), levels(plot$data$recipient))
  expect_equal(unname(plot$scales$get_scales("x")$labels),
    c("patient\rB", "staff\rB", "patient\rA", "staff\rA"))
  expect_equal(plot$scales$get_scales("x")$labels,
    plot$scales$get_scales("y")$labels)
  observed <- plot$data[plot$data$transmissions > 0, ]
  expect_equal(as.character(observed$source), c("2", "4"))
  expect_equal(as.character(observed$recipient), c("3", "1"))
  expect_equal(sum(plot$data$transmissions == 0), 14L)
  expect_no_warning(ggplot2::ggplotGrob(plot))
})

test_that("single groups, missing attributes and empty outbreaks render", {
  outbreak <- tmat_outbreak()
  outbreak$population$ward[1] <- NA
  plot <- plot_tmat(outbreak, "ward")
  expect_true("(Missing)" %in% plot$scales$get_scales("x")$labels)
  expect_equal(sum(plot$data$transmissions), 2L)
  expect_no_warning(ggplot2::ggplotGrob(plot))

  outbreak$infections <- outbreak$infections[1, ]
  plot <- plot_tmat(outbreak, "role")
  expect_equal(nrow(plot$data), 4L)
  expect_true(all(plot$data$transmissions == 0L))
  expect_no_warning(ggplot2::ggplotGrob(plot))
  outbreak$infections <- outbreak$infections[0, ]
  expect_equal(plot_tmat(outbreak, "role")$data, plot$data)

  outbreak$population <- outbreak$population[0, ]
  plot <- plot_tmat(outbreak, "role")
  expect_equal(nrow(plot$data), 0L)
  expect_no_warning(ggplot2::ggplotGrob(plot))
})

test_that("grouping attributes are validated", {
  outbreak <- tmat_outbreak()
  for (by in list(character(), c("role", "role"), NA_character_, "absent")) {
    expect_error(plot_tmat(outbreak, by), "distinct population attributes")
  }
})
