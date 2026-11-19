library(nososim)

outbreak <- local({
  population <- make_population(
    make_landscape(list(hospital = list(A = 20, B = 20))),
    arrivals = function(data, t) data$available,
    attributes = function(data, t) {
      dplyr::mutate(data,
        ward = level_2,
        role = sample(c("patient", "staff"), dplyr::n(), replace = TRUE,
          prob = c(0.8, 0.2)
        ),
        stay = sample(5:20, dplyr::n(), replace = TRUE),
        tau = 0.08
      )
    },
    update = function(data, t) {
      dplyr::mutate(data,
        stay = stay + dplyr::if_else(date_infection == .env$t, 3L, 0L,
          missing = 0L
        )
      )
    }
  )

  dates <- as.Date("2026-01-01") + 0:20
  set.seed(123)
  make_outbreak(
    population,
    dates = dates,
    w = c(0, 0.5, 0.3, 0.2),
    imported = function(data, t) {
      if (t == dates[1]) head(data$labels, 1) else character()
    },
    contacts = function(data, t) {
      nososim::get_contacts(data, by = "level_1")
    }
  )
})

outbreak$infections
count_edges(outbreak, by = c("ward", "role"))
autoplot(outbreak)
