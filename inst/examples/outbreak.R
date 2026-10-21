library(nososim)

set.seed(123)
dates <- as.Date("2026-01-01") + 0:13
timeline <- make_timeline(
  n = 40, dates = dates, stay = 14, R = 2,
  attributes = list(ward = c(A = 0.5, B = 0.5))
)
initial <- data.frame(id = "ID_1", date_infection = dates[1])
intervention <- function(present, date) {
  matrix(
    0, nrow(present), nrow(present),
    dimnames = list(present$id, present$id)
  )
}
outbreak <- make_outbreak(
  timeline, initial = initial, w = c(0.2, 0.5, 0.3),
  dates = dates, intervention = intervention
)
summary(timeline)
summary(outbreak)
print(autoplot(timeline))
print(autoplot(outbreak))
