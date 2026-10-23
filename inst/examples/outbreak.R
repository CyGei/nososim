library(nososim)

set.seed(123)
dates <- as.Date("2026-01-01") + 0:20
timeline <- make_timeline(
  n = 40,
  dates = dates,
  stay = 5:20,
  admission_delay = 0:5,
  R = 2.5,
  attributes = list(
    ward = c(A = 0.5, B = 0.5),
    role = c(patient = 0.8, staff = 0.2)
  )
)
imported <- timeline[1, c("id", "date")]
intervention <- function(present, date) {
  matrix(
    0,
    nrow(present),
    nrow(present),
    dimnames = list(present$id, present$id)
  )
}
outbreak <- make_outbreak(
  timeline,
  imported = imported,
  w = c(0.2, 0.5, 0.3),
  dates = dates,
  intervention = intervention
)
summary(timeline)
summary(outbreak)
autoplot(timeline)
autoplot(outbreak) + ggplot2::aes(fill = ward, colour = ward)
