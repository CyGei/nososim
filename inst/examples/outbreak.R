library(nososim)

set.seed(123)
dates <- as.Date("2026-01-01") + 0:20
population <- make_population(
  make_landscape(list(hospital = c(A = 20, B = 20))), dates,
  admissions = function(landscape, date) {
    if (date == dates[1]) landscape$available else integer(nrow(landscape))
  },
  individuals = function(admitted, date) {
    dplyr::mutate(admitted,
      id = paste0("ID_", dplyr::row_number()),
      ward = level_2,
      role = sample(c("patient", "staff"), dplyr::n(), replace = TRUE,
        prob = c(0.8, 0.2)
      ),
      start = date, end = date + sample(5:20, dplyr::n(), replace = TRUE) - 1L,
      tau = 0.08
    )
  }
)
outbreak <- make_outbreak(
  population, data.frame(id = "ID_1", date_infection = dates[1]),
  w = c(0.2, 0.5, 0.3), dates = dates,
  contacts = function(present, date) {
    nososim::get_contacts(present, date, by = "level_1")
  }
)

outbreak$infections
count_edges(outbreak, by = c("ward", "role"))
autoplot(population)
