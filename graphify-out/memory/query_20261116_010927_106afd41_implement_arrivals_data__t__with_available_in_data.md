---
type: "query"
date: "2026-11-16T01:09:27.252710+00:00"
question: "Implement arrivals(data, t) with available in data, and clarify whether update can apply any rule checked at time t."
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_population()", "admit_individuals()", "update_population()"]
---

# Q: Implement arrivals(data, t) with available in data, and clarify whether update can apply any rule checked at time t.

## Answer

Implemented the accepted callback simplification: arrivals now receives (data, t), where data is the landscape plus freshly calculated available capacity. Updated R examples, README, vignette, methods, generated help, tests and the packaged example. Retained make_population and simulacr names labels, t, date_infection, from, to and date, as explicitly requested; prior renaming recommendations were rejected. update may evaluate any time-dependent or conditional attribute rule within the existing row/identity/location/infection constraints. Returned attributes carry to subsequent days until overwritten; update runs after transmission and before departures. Existing occupancy tests now verify callback metadata, dates and capacity. The full test suite has only the previously known zero-sum w validation failure. README and vignette code runs, skipping the user debugger line in the temporary evaluation. Seeded example scripts before and after the interface change produce identical population and infections. graphify update . completed without LLM calls and reported 69 missing source_file metadata warnings.

## Outcome

- Signal: useful

## Source Nodes

- make_population()
- admit_individuals()
- update_population()