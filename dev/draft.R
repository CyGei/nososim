devtools::load_all()
library(ggplot2)
library(dplyr)

set.seed(123)
start <- as.Date("2026-01-01")
dates <- start + 0:13

timeline <- make_timeline(
  n = 40,
  dates = dates,
  attributes = list(
    ward = c(A = 0.5, B = 0.5),
    group = c(patient = 0.8, staff = 0.2)
  ),
  admission_delay = 0:4,
  stay = 3:7,
  R = rpois(40, 2.5)
)
summary(timeline)

autoplot(timeline, aes(colour = ward)) +
  facet_grid(
    rows = vars(group),
    scales = "free_y",
    space = "free_y"
  ) +
  paletteer::scale_colour_paletteer_d("ltc::trio1")

timeline <- timeline |>
  #modify an ID timeline
  set_attribute(
    id = "ID_36",
    from = start + 6,
    attributes = list(ward = "A")
  ) |>
  #give 2 day breaks to a all staff members
  group_by(id) |>
  (\(x) {
    set_schedule(
      x,
      id = unique(x$id[x$group == "staff"]),
      weekdays = sample(1:7, 5)
    )
  })() |>
  ungroup() |>
  new_timeline()

autoplot(timeline, aes(colour = ward)) +
  facet_grid(
    rows = vars(group),
    scales = "free_y",
    space = "free_y"
  ) +
  paletteer::scale_colour_paletteer_d("ltc::trio1")

# Choose relative diffusion weights: rows are sources, columns are recipients.
ward_weights <- tribble(
  ~from , ~A   , ~B   ,
  "A"   , 1    , 0.25 ,
  "B"   , 0.25 , 1
) |>
  tibble::column_to_rownames("from") |>
  as.matrix()

group_weights <- tribble(
  ~from     , ~patient , ~staff ,
  "patient" ,        1 ,      2 ,
  "staff"   ,        2 ,      1
) |>
  tibble::column_to_rownames("from") |>
  as.matrix()


# Specify E(t): a 50% reduction on every route from day 4 onwards.
intervention <- function(present, date) {
  matrix(
    if (date >= start + 4) 0.5 else 0,
    nrow = nrow(present),
    ncol = nrow(present),
    dimnames = list(present$id, present$id)
  )
}


outbreak <- make_outbreak(
  timeline = timeline,
  initial = timeline |>
    filter(date == start) |>
    slice_head(n = 1, by = ward) |>
    transmute(id, date_infection = date),
  w = distcrete::distcrete(
    "gamma",
    shape = 4,
    rate = 4 / 2,
    interval = 1
  )$d(0:10) |>
    (\(w) w / sum(w))(),
  dates = dates,
  intervention = intervention,
  mixing = list(ward = ward_weights, group = group_weights)
)
outbreak

# F. Overlay the transmission tree on the same timelines.
autoplot(
  outbreak,
  aes(colour = ward, fill = ward, shape = group)
) +
  scale_shape_manual(values = c(patient = 21, staff = 24)) +
  paletteer::scale_fill_paletteer_d("ltc::trio1") +
  paletteer::scale_colour_paletteer_d("ltc::trio1")


