---
type: "query"
date: "2026-11-13T13:54:02.264049+00:00"
question: "Review the suggestions for strictly minimal requirements and provide the final API from A to Z."
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_population()", "make_outbreak()", "get_contacts()"]
---

# Q: Review the suggestions for strictly minimal requirements and provide the final API from A to Z.

## Answer

Final proposed minimal API review, not implemented: keep make_landscape, make_population, make_outbreak as core public verbs, plus existing contact and result helpers. make_population always builds explicit nososim_population; no dates, initial, public population_step, or extra preview runner. It retains admissions(landscape,date), individuals(admitted,date), and optional departures(present,date). User supplies baseline stay duration, not duplicate los/start/planned_end/end; engine owns start and realised end, generates IDs when omitted, and preserves supplied IDs for repeated staff shifts. Default departure is elapsed days >= stay; custom departure replaces default and can read current infection history. Draw baseline stay/extra stay once. make_outbreak owns dates and stochastic realization; tau defaults to column, w explicit, imported=NULL means no seeds. Imported may be known-ID table or after-admission callback returning id/date_infection, enabling generated-ID seeding and infection-free lead-in. Known dated imports apply before departure; callback introductions after admissions influence subsequent departure decisions. Contact snapshots must never be filtered by expired baseline end; get_contacts can accept date=NULL for already-present snapshots and retain date filtering on realised history. Keep actual presence and infections as primary output tables with dates/parameters, ongoing boundary metadata and plotting metadata. No duplicated tree table, individual registry/events output unless needed. Named list composes groups. Current population constructor meaning changes deliberately; do not support dual return types. Expanded graph terms: make_landscape make_population make_outbreak admissions individuals get_contacts offspring. No source code changes.

## Outcome

- Signal: useful

## Source Nodes

- make_population()
- make_outbreak()
- get_contacts()