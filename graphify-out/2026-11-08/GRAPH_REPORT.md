# Graph Report - nososim  (2026-11-08)

## Corpus Check
- 42 files · ~20,477 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 23 file(s) not represented in the graph (top: .Rd 12, (none) 8, .Rmd 2)

## Summary
- 241 nodes · 207 edges · 44 communities (29 shown, 15 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `0c5059d3`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- test-make_outbreak.R
- autoplot.nososim_outbreak
- Pairwise infection hazard
- draft.R
- test-timeline.R
- examples/outbreak.R
- count_edges
- test-autoplot.R
- Graphify knowledge graph
- R-CMD-check workflow
- Cyril Geismar
- Q: Explain the link between reduction and intervention and whether the code can be simplified in tidy R.
- nososim
- Q: Use one concise consistent sampler interface for population generation.
- nososim_validation.qmd
- timeline.R
- test-count_edges.R
- Q: Which existing nososim conventions should guide a landscape API?
- Q: Review the current code against main and suggest a very concise simple landscape and population implementation matching the whiteboard.
- Q: What is the best architecture for generating people through time from the current landscape, with location-specific admissions, lengths of stay and dynamically drawn attributes?
- test-landscape.R
- Q: Focus only on make_landscape from the vignette nested hospital/ward/room list and remove unnecessary experimental population and timeline changes.
- flatten
- Q: Use n instead of capacity. Should admission rates belong to make_landscape or elsewhere, and what is the most elegant approach?
- Q: Implement admission rates as location-table columns in the vignette and show the next step.
- Q: How does our current landscape, timeline and population generation compare with an arrivals-driven, capacity-constrained hospital ward model, and what is the simplest clear robust generic approach?
- Q: Implement landscape-conditioned population generation with hierarchical admission_rate and los specifications.
- Q: How would you construct make_population? Be clear concise and tidy.
- test-population.R
- tibble::tibble
- Q: Show an executable vignette example of the proposed make_population with user-customizable admissions and explain how individuals are generated.
- Q: Insert the agreed make_population into the package and update the vignette with clean concise generic R code and documentation.
- Q: Review the current vignette and user workflow for API cleanliness: are admissions columns defaults, or are location columns and admission/individual functions user defined?
- Q: Update the vignette and documentation around the agreed clean workflow, clearly separating user inputs from generated population fields.

## God Nodes (most connected - your core abstractions)
1. `count_edges()` - 6 edges
2. `autoplot.nososim_outbreak()` - 5 edges
3. `Pairwise infection hazard` - 5 edges
4. `make_outbreak()` - 4 edges
5. `make_timeline()` - 4 edges
6. `nososim` - 4 edges
7. `Q: Which existing nososim conventions should guide a landscape API?` - 4 edges
8. `Q: How does our current landscape, timeline and population generation compare with an arrivals-driven, capacity-constrained hospital ward model, and what is the simplest clear robust generic approach?` - 4 edges
9. `Q: Implement landscape-conditioned population generation with hierarchical admission_rate and los specifications.` - 4 edges
10. `Q: Use one concise consistent sampler interface for population generation.` - 4 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (44 total, 15 thin omitted)

### Community 0 - "test-make_outbreak.R"
Cohesion: 0.10
Nodes (18): blocked, excluded, expected, imported, invalid, outbreak, patient, present (+10 more)

### Community 1 - "autoplot.nososim_outbreak"
Cohesion: 0.17
Nodes (6): autoplot.nososim_outbreak(), autoplot.nososim_timeline(), make_outbreak(), mixing_matrix(), transmission_hazards(), make_population()

### Community 2 - "Pairwise infection hazard"
Cohesion: 0.16
Nodes (10): Baseline daily infectiousness, Baseline reproduction number, Daily transmission simulation, Diffusion matrices, Generation time PMF, Time-varying intervention matrix, Pairwise diffusion weights, Pairwise infection hazard (+2 more)

### Community 3 - "draft.R"
Cohesion: 0.20
Nodes (6): dates, outbreak, role_weights, start, timeline, ward_weights

### Community 4 - "test-timeline.R"
Cohesion: 0.20
Nodes (9): dates, expected, monday, people, scheduled, start, timeline, updated (+1 more)

### Community 5 - "examples/outbreak.R"
Cohesion: 0.22
Nodes (4): dates, imported, outbreak, timeline

### Community 8 - "test-autoplot.R"
Cohesion: 0.33
Nodes (5): layers, outbreak, segments, start, timeline

### Community 19 - "Q: Explain the link between reduction and intervention and whether the code can be simplified in tidy R."
Cohesion: 0.50
Nodes (3): Answer, Q: Explain the link between reduction and intervention and whether the code can be simplified in tidy R., Source Nodes

### Community 20 - "nososim"
Cohesion: 0.40
Nodes (4): A first outbreak, Go further, Installation, nososim

### Community 21 - "Q: Use one concise consistent sampler interface for population generation."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Use one concise consistent sampler interface for population generation., Source Nodes

### Community 22 - "nososim_validation.qmd"
Cohesion: 0.33
Nodes (5): Add a scenario: block ward A → ward B, Checks and figures, Outputs, Scenarios, Simulation

### Community 23 - "timeline.R"
Cohesion: 0.32
Nodes (3): draw(), make_timeline(), new_timeline()

### Community 24 - "test-count_edges.R"
Cohesion: 0.20
Nodes (9): aggregated, columns, daily, date, dates, empty, joint, outbreak (+1 more)

### Community 27 - "Q: Which existing nososim conventions should guide a landscape API?"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Which existing nososim conventions should guide a landscape API?, Source Nodes

### Community 28 - "Q: Review the current code against main and suggest a very concise simple landscape and population implementation matching the whiteboard."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Review the current code against main and suggest a very concise simple landscape and population implementation matching the whiteboard., Source Nodes

### Community 29 - "Q: What is the best architecture for generating people through time from the current landscape, with location-specific admissions, lengths of stay and dynamically drawn attributes?"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: What is the best architecture for generating people through time from the current landscape, with location-specific admissions, lengths of stay and dynamically drawn attributes?, Source Nodes

### Community 30 - "test-landscape.R"
Cohesion: 0.50
Nodes (3): landscape, locations, wards

### Community 31 - "Q: Focus only on make_landscape from the vignette nested hospital/ward/room list and remove unnecessary experimental population and timeline changes."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Focus only on make_landscape from the vignette nested hospital/ward/room list and remove unnecessary experimental population and timeline changes., Source Nodes

### Community 33 - "Q: Use n instead of capacity. Should admission rates belong to make_landscape or elsewhere, and what is the most elegant approach?"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Use n instead of capacity. Should admission rates belong to make_landscape or elsewhere, and what is the most elegant approach?, Source Nodes

### Community 34 - "Q: Implement admission rates as location-table columns in the vignette and show the next step."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Implement admission rates as location-table columns in the vignette and show the next step., Source Nodes

### Community 35 - "Q: How does our current landscape, timeline and population generation compare with an arrivals-driven, capacity-constrained hospital ward model, and what is the simplest clear robust generic approach?"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: How does our current landscape, timeline and population generation compare with an arrivals-driven, capacity-constrained hospital ward model, and what is the simplest clear robust generic approach?, Source Nodes

### Community 36 - "Q: Implement landscape-conditioned population generation with hierarchical admission_rate and los specifications."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Implement landscape-conditioned population generation with hierarchical admission_rate and los specifications., Source Nodes

### Community 37 - "Q: How would you construct make_population? Be clear concise and tidy."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: How would you construct make_population? Be clear concise and tidy., Source Nodes

### Community 38 - "test-population.R"
Cohesion: 0.17
Nodes (8): a, dates, drawn, individuals(), locations, population, present, seen

### Community 39 - "tibble::tibble"
Cohesion: 0.33
Nodes (3): offspring(), simple_outbreak(), hazard_fixture()

### Community 40 - "Q: Show an executable vignette example of the proposed make_population with user-customizable admissions and explain how individuals are generated."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Show an executable vignette example of the proposed make_population with user-customizable admissions and explain how individuals are generated., Source Nodes

### Community 41 - "Q: Insert the agreed make_population into the package and update the vignette with clean concise generic R code and documentation."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Insert the agreed make_population into the package and update the vignette with clean concise generic R code and documentation., Source Nodes

### Community 42 - "Q: Review the current vignette and user workflow for API cleanliness: are admissions columns defaults, or are location columns and admission/individual functions user defined?"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Review the current vignette and user workflow for API cleanliness: are admissions columns defaults, or are location columns and admission/individual functions user defined?, Source Nodes

### Community 43 - "Q: Update the vignette and documentation around the agreed clean workflow, clearly separating user inputs from generated population fields."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Update the vignette and documentation around the agreed clean workflow, clearly separating user inputs from generated population fields., Source Nodes

## Knowledge Gaps
- **9 isolated node(s):** `R-CMD-check workflow`, `R package check`, `Cyril Geismar`, `MIT License`, `Baseline reproduction number` (+4 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 181 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `hazard_fixture()` connect `tibble::tibble` to `test-make_outbreak.R`?**
  _High betweenness centrality (0.003) - this node is a cross-community bridge._
- **What connects `R-CMD-check workflow`, `R package check`, `Cyril Geismar` to the rest of the system?**
  _9 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `test-make_outbreak.R` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._