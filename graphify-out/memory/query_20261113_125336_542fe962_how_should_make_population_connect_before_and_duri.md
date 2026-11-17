---
type: "query"
date: "2026-11-13T12:53:36.375849+00:00"
question: "How should make_population connect before and during make_outbreak with the smallest elegant R API?"
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_population()", "make_outbreak()"]
---

# Q: How should make_population connect before and during make_outbreak with the smallest elegant R API?

## Answer

Recommended minimal API revision: make_landscape remains unchanged; make_population consistently constructs an explicit population model (landscape, optional initial records, admissions and individuals rules, optional departures rule), rather than precomputing future attendance. It has no date horizon and performs no stochastic run. make_outbreak owns dates and the sole loop, reusing these retained rules before transmission. Do not expose population_step(state,date): it leaks bookkeeping to users. The default departure rule is date > baseline end; custom departures(present,date) sees infection history and returns a logical vector, allowing a once-drawn extension without cumulative redrawing. Keep functions/tables explicit in a list-based model, not hidden tibble attributes. Multiple populations compose as a named list in make_outbreak, preserving independent capacities and fixed staff identity across shifts. Optional initial tibble supports existing residents; otherwise first-day admission rules initialise the population. Seed selection for generated IDs needs an imported callback evaluated after admission or explicit initial residents with known IDs. Actual realised presence is returned in outbreak$population, alongside infections. A standard simulate(population, dates) S3 method is an optional useful demographic preview sharing the same internal kernel; not a second population builder. This changes the existing meaning of make_population deliberately and must be documented as a migration. Expanded graph terms: make_population make_outbreak admissions individuals landscape. Proposal only, no code implemented.

## Outcome

- Signal: useful

## Source Nodes

- make_population()
- make_outbreak()