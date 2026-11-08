---
type: "query"
date: "2026-11-06T15:46:30.688795+00:00"
question: "Show an executable vignette example of the proposed make_population with user-customizable admissions and explain how individuals are generated."
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_landscape()"]
---

# Q: Show an executable vignette example of the proposed make_population with user-customizable admissions and explain how individuals are generated.

## Answer

Extended only vignettes/articles/nososim.Rmd with an executable prototype and worked examples; no exported production population API was added. Proposed interface make_population(locations, dates, admissions, individuals). admissions(locations, date) is user supplied and returns attempted nonnegative integer counts per room in row order; example Poisson arrivals halves rates on weekends, and prose shows deterministic one-per-room alternative. Simulator caps counts by free places, expands them with uncount, and assigns unique IDs plus admission dates before calling individuals(people, date). That user function preserves supplied rows and adds age, sex, patient role and positive integer LOS drawn conditional on ward and previously sampled age. A two-person same-room input is printed before/after individual generation. The simulator records exclusive discharge dates and retains an admission history. It starts empty and excess arrivals leave. Vignette renders, producing sixty people over fourteen days with seed 123. Independently verified per-room occupancy limits, conditional LOS ranges, arbitrary deterministic and weekday-only arrival callbacks, exact discharge-day reuse, zero arrivals without calling individuals, and rejection of invalid counts. git diff --check passes and graphify update . completed with existing external-node source metadata warnings.

## Outcome

- Signal: useful

## Source Nodes

- make_landscape()