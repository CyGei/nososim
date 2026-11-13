simple_outbreak <- function() {
  dates <- as.Date("2026-01-01") + 0:1
  population <- tibble::tibble(
    id = c("ID_1", "ID_2"), level_1 = "hospital",
    start = dates[1], end = dates[2], tau = 1000
  )
  make_outbreak(
    population, tibble::tibble(id = "ID_1", date_infection = dates[1]),
    w = 1, dates = dates, contacts = get_contacts
  )
}
