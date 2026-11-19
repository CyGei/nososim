---
type: "query"
date: "2026-11-06T09:50:34.296712+00:00"
question: "Implement landscape-conditioned population generation with hierarchical admission_rate and los specifications."
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_population()", "location_rules()", "population_intervals()", "as_daily()"]
---

# Q: Implement landscape-conditioned population generation with hierarchical admission_rate and los specifications.

## Answer

Implemented the agreed arrivals-driven workflow in R/population.R: make_population(landscape, dates, admission_rate, los, initial_occupancy, initial_los, attributes), followed by as_daily(population). Expanded graph vocabulary: landscape, population, timeline, admission, stays. Rule trees follow landscape paths and may stop at any level; each area generates one arrival stream, allocated uniformly among its free beds. Numeric admission rates are Poisson means per day; function(date) returns custom or observed integer counts. LOS supports fixed days, a finite numeric distribution sampled uniformly, or function(n) returning n positive integer days. Initial occupancy is an exact rounded fraction of each configured area's capacity. Numeric LOS supports equilibrium length-weighted initial residuals; custom LOS functions require explicit remaining-day rules for occupied areas. The first date is the census; arrival streams run from the second date. Exclusive departures free beds before arrivals. Overflow leaves the model and is recorded in population$admissions as arrivals, admitted and unadmitted counts by scope. People and stays remain linked through IDs and existing daily attendance/outbreak APIs work. Existing precomputed-stay callers are retained. Updated function docs, README, getting-started guide and packaged example data. Added 12 admission-flow tests. The full suite passes; README and guide render; R CMD check reports zero errors, warnings and notes. graphify update . rebuilt the code graph to 260 nodes, 259 edges; extractor warnings concern external source metadata and some symbol-free R files.

## Outcome

- Signal: useful

## Source Nodes

- make_population()
- location_rules()
- population_intervals()
- as_daily()