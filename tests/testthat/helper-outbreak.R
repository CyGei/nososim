run_outbreak <- function(population, dates = as.Date("2026-01-01"), w = 1,
                         imported = function(data, t) character(),
                         contacts = function(data, t) get_contacts(data)) {
  make_outbreak(population, dates, w, imported, contacts)
}
