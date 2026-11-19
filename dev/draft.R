devtools::load_all()
library(ggplot2)
library(dplyr)

source("inst/examples/outbreak.R")
start <- dates[1]

# Plot stays by ward and role.
autoplot(population, aes(colour = ward)) +
  facet_grid(rows = vars(role), scales = "free_y", space = "free_y")

# Choose contact intensity multipliers: rows are sources, columns are recipients.
ward_multipliers <- tribble(
  ~from , ~A   , ~B   ,
  "A"   , 1    , 0.25 ,
  "B"   , 0.25 , 1
) |>
  tibble::column_to_rownames("from") |>
  as.matrix()

role_multipliers <- tribble(
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
  population = population,
  imported = population |>
    slice_head(n = 1, by = ward) |>
    transmute(id, date_infection = start),
  w = distcrete::distcrete(
    "gamma",
    shape = 4,
    rate = 4 / 2,
    interval = 1
  )$d(0:10) |>
    (\(w) w / sum(w))(),
  dates = dates,
  contacts = function(present, date) {
    get_contacts(present, date, by = "level_1",
      multipliers = list(ward = ward_multipliers, role = role_multipliers)
    )
  },
  intervention = intervention
)
outbreak

# Summarise transmissions using attributes on the contact date.
count_edges(outbreak, by = c("ward", "role"))
offspring(outbreak)
