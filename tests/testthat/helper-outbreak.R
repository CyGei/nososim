simple_outbreak <- function() {
  dates <- as.Date("2026-01-01") + 0:1
  population <- make_population(
    make_landscape(list(hospital = 2)),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) {
      dplyr::mutate(data,
        labels = c("ID_1", "ID_2"), ward = "A", role = "patient",
        stay = 2L, tau = 1000
      )
    }
  )
  make_outbreak(population, dates, w = c(0, 1),
    imported = function(data, t) {
      if (t == dates[1]) "ID_1" else character()
    },
    contacts = function(data, t) get_contacts(data)
  )
}
