---
type: "query"
date: "2026-11-16T00:23:24.697775+00:00"
question: "Can we simplify the population and outbreak workflow while retaining attributes and stays that change during the outbreak?"
contributor: "graphify"
outcome: "corrected"
correction: "Preserve dynamic attributes, infection-dependent stays, and resulting admission feedback. Simplify state representation and daily orchestration instead of precomputing attendance or removing updates."
source_nodes: ["make_population()", "make_outbreak()"]
---

# Q: Can we simplify the population and outbreak workflow while retaining attributes and stays that change during the outbreak?

## Answer

Expanded graph vocabulary: population outbreak update attributes stay. The user explicitly retains infection-dependent attributes and stays. The previous recommendation to precompute attendance and exclude feedback was inappropriate. Current population definition callbacks (arrivals, attributes, update) and the single daily coupled loop are appropriate. Simplification should focus on one authoritative current-occupant table, an infection ledger retained across absence, and immutable daily snapshots; avoid repeated current-list -> present -> per-group reconstruction. Keep separate capacity pools as grouping keys, not separate evolving population containers. Extract only cohesive admission and attribute-update operations; keep the simulacr call and daily phase order visible. Keep update after transmission before departures. Existing infection dates can be updated directly from step$date_infection for current rows, with ledger lookup needed for returning entrants, avoiding full ledger matches each phase. Do not add a composite class or combine_populations function just to replace a named list unless it materially improves the user API. Clear callback contracts and one population definition are enough; a final realized future attendance table is not required or appropriate. Review only, no code modifications.

## Outcome

- Signal: corrected
- Correction: Preserve dynamic attributes, infection-dependent stays, and resulting admission feedback. Simplify state representation and daily orchestration instead of precomputing attendance or removing updates.

## Source Nodes

- make_population()
- make_outbreak()