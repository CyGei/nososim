---
type: "query"
date: "2026-11-16T00:31:31.683934+00:00"
question: "Implement and independently assess a simpler dynamic simulation while retaining the patient and staff vignette as reference."
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_outbreak()", "make_population()", "admit_individuals()", "update_population()"]
---

# Q: Implement and independently assess a simpler dynamic simulation while retaining the patient and staff vignette as reference.

## Answer

Implemented one persistent current-occupant tibble in make_outbreak; independent capacity pools use population and .location columns. admit_individuals now computes availability and counts for one model. New update_population helper validates and applies per-model changes before a common departure filter. Main loop retains explicit admissions, imports, contact-time snapshots, simulacr call, state update, attribute updates, and departures. Current dates come directly from step$date_infection, with step$S mapped to missing; infection ledger restores returning entrants. Model/person order retained for random draws. Public API unchanged. Population docs and vignette prose clarify definition versus runtime. Added mixed patient/staff test for local-infection stay extension and independent rotating staff capacity. All tests pass; rendered vignette matches baseline exactly (1015 attendance rows, 16 infections). Independent agent found no correctness issues; 20 seeded mixed-model comparisons matched events and column values, including pre-1970 dates. Minor output column-order difference possible with a shallower model first. R CMD check: 0 errors, 0 warnings, 1 unavailable remote clock verification note. graphify update completed with source metadata extraction warnings.

## Outcome

- Signal: useful

## Source Nodes

- make_outbreak()
- make_population()
- admit_individuals()
- update_population()