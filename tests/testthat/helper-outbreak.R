simple_outbreak <- function() {
  dates <- as.Date("2026-01-01") + 0:1
  make_outbreak(
    make_timeline(2, dates, stay = 2, R = 1000),
    tibble::tibble(id = "ID_1", date = dates[1]),
    w = 1, dates = dates,
    intervention = function(present, date) {
      matrix(0, nrow(present), nrow(present),
        dimnames = list(present$id, present$id)
      )
    }
  )
}
