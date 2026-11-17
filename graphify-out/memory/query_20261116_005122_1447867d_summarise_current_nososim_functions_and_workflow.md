---
type: "query"
date: "2026-11-16T00:51:22.776201+00:00"
question: "Summarise current nososim functions and workflow, compare with the previous commit, and recommend the simplest clear maintainable user API."
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_population()", "make_outbreak()", "get_contacts()", "offspring()", "update_population()"]
---

# Q: Summarise current nososim functions and workflow, compare with the previous commit, and recommend the simplest clear maintainable user API.

## Answer

Expanded from graph vocabulary: population outbreak landscape contacts mixing offspring timeline admissions update. Verified the graph against current source and git revisions. Current working tree defines reusable population rules in make_population, then make_outbreak runs admissions, imports, pre-transmission snapshots, simulacr transmission, persistent updates, and departures. HEAD 916c7be precomputes stay records with make_population before simulating infections; parent 0487185 uses make_timeline and an in-package normalised R_i hazard engine. Current architecture supports infection-dependent stays and admission feedback, separate capacity pools and preserved infection histories. Recommend retaining the current single daily engine, clarifying that make_population returns a model, making callback signatures consistent, and choosing stable identity/date names. Current get_contacts is a pure current-occupants matrix builder; offspring and count_edges summarise event history. Current core population/outbreak files have 296 nonblank noncomment lines versus 162 in HEAD, so the interface is smaller but the dynamic engine is not shorter. Review found contacts = get_contacts errors because the date is passed as by; vignette line 180 contains debugonce(make_outbreak); devtools::test has one failure at test-make_outbreak.R:269 because zero-sum numeric w is accepted by the pinned simulacr PMF constructor. No package code was edited.

## Outcome

- Signal: useful

## Source Nodes

- make_population()
- make_outbreak()
- get_contacts()
- offspring()
- update_population()