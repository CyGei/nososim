---
type: "query"
date: "2026-11-06T15:30:06.532372+00:00"
question: "Implement admission rates as location-table columns in the vignette and show the next step."
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_landscape()"]
---

# Q: Implement admission rates as location-table columns in the vignette and show the next step.

## Answer

Added a Define admission rates section to vignettes/articles/nososim.Rmd. It uses locations |> mutate(admission_rate = if_else(location_2 == "A", 0.8, 1.2)), then prints the result. Prose defines admission_rate as mean attempted entries per room per day, n as the occupancy limit, and distinguishes a ward-wide stream sampled only once from repeated room-level rates. Constructor and function arguments remain unchanged. Rendered the vignette and verified all ten room rates, ten terminal rows and twenty-seven total places. git diff --check passes; graphify update . completed. The next proposed step, not implemented here, is the make_population daily allocation process: release departures, draw attempted arrivals per room (Poisson if that distribution is adopted), cap admissions at n minus current occupancy, then draw attributes and location-conditioned LOS for admitted individuals and record their discharge dates.

## Outcome

- Signal: useful

## Source Nodes

- make_landscape()