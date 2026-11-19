# Graph Report - nososim  (2026-11-10)

## Corpus Check
- 46 files · ~22,330 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 23 file(s) not represented in the graph (top: .Rd 12, (none) 8, .Rmd 2)

## Summary
- 275 nodes · 242 edges · 46 communities (32 shown, 14 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `88ac8906`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- test-make_outbreak.R
- autoplot.nososim_population
- Pairwise infection hazard
- draft.R
- test-timeline.R
- examples/outbreak.R
- count_edges
- test-autoplot.R
- Graphify knowledge graph
- R-CMD-check workflow
- Cyril Geismar
- Q: Restore the nested landscape stay plot for autoplot using the current make_population output, keeping code concise.
- test-get_contacts.R
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
- collect_levels
- Q: Use n instead of capacity. Should admission rates belong to make_landscape or elsewhere, and what is the most elegant approach?
- Q: Implement admission rates as location-table columns in the vignette and show the next step.
- Q: How does our current landscape, timeline and population generation compare with an arrivals-driven, capacity-constrained hospital ward model, and what is the simplest clear robust generic approach?
- Q: Implement landscape-conditioned population generation with hierarchical admission_rate and los specifications.
- Q: How would you construct make_population? Be clear concise and tidy.
- test-population.R
- Q: Generate individuals only when places are available; avoid computing rejected people while keeping user-defined complete records.
- Q: Show an executable vignette example of the proposed make_population with user-customizable admissions and explain how individuals are generated.
- Q: Insert the agreed make_population into the package and update the vignette with clean concise generic R code and documentation.
- Q: Review the current vignette and user workflow for API cleanliness: are admissions columns defaults, or are location columns and admission/individual functions user defined?
- Q: Update the vignette and documentation around the agreed clean workflow, clearly separating user inputs from generated population fields.

## God Nodes (most connected - your core abstractions)
1. `autoplot.nososim_population()` - 7 edges
2. `count_edges()` - 6 edges
3. `collect_levels()` - 6 edges
4. `get_contacts()` - 5 edges
5. `make_population()` - 5 edges
6. `Pairwise infection hazard` - 5 edges
7. `population_positions()` - 4 edges
8. `make_outbreak()` - 4 edges
9. `make_timeline()` - 4 edges
10. `nososim` - 4 edges

## Surprising Connections (you probably didn't know these)
- `get_contacts()` --calls--> `tibble::as_tibble()`  [EXTRACTED]
  R/get_contacts.R →   _Bridges community 1 → community 6_
- `collect_levels()` --calls--> `tibble::tibble()`  [EXTRACTED]
  R/landscape.R →   _Bridges community 32 → community 0_
- `make_population()` --calls--> `dplyr::mutate()`  [EXTRACTED]
  R/population.R →   _Bridges community 1 → community 38_
- `make_population()` --calls--> `tibble::new_tibble()`  [EXTRACTED]
  R/population.R →   _Bridges community 1 → community 23_

## Import Cycles
- None detected.

## Communities (46 total, 14 thin omitted)

### Community 0 - "test-make_outbreak.R"
Cohesion: 0.08
Nodes (21): offspring(), simple_outbreak(), blocked, excluded, expected, hazard_fixture(), imported, invalid (+13 more)

### Community 1 - "autoplot.nososim_population"
Cohesion: 0.15
Nodes (6): autoplot.nososim_population(), population_positions(), make_outbreak(), mixing_matrix(), transmission_hazards(), make_population()

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

### Community 6 - "count_edges"
Cohesion: 0.17
Nodes (3): count_edges(), add_attributes(), get_contacts()

### Community 8 - "test-autoplot.R"
Cohesion: 0.17
Nodes (10): before, landscape, layers, outbreak, plot, population, rows, segments (+2 more)

### Community 14 - "Q: Restore the nested landscape stay plot for autoplot using the current make_population output, keeping code concise."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Restore the nested landscape stay plot for autoplot using the current make_population output, keeping code concise., Source Nodes

### Community 15 - "test-get_contacts.R"
Cohesion: 0.40
Nodes (4): contacts, date, expected, population

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
Nodes (3): hospital, landscape, wards

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
Cohesion: 0.12
Nodes (12): a, dates, drawn, expected, individuals(), landscape, observed, original (+4 more)

### Community 39 - "Q: Generate individuals only when places are available; avoid computing rejected people while keeping user-defined complete records."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Generate individuals only when places are available; avoid computing rejected people while keeping user-defined complete records., Source Nodes

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
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 208 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **14 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `make_population()` connect `autoplot.nososim_population` to `test-population.R`, `timeline.R`?**
  _High betweenness centrality (0.022) - this node is a cross-community bridge._
- **What connects `R-CMD-check workflow`, `R package check`, `Cyril Geismar` to the rest of the system?**
  _9 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `test-make_outbreak.R` be split into smaller, more focused modules?**
  _Cohesion score 0.07692307692307693 - nodes in this community are weakly interconnected._
- **Why does `get_contacts()` connect `count_edges` to `autoplot.nososim_population`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._
- **Should `autoplot.nososim_population` be split into smaller, more focused modules?**
  _Cohesion score 0.14705882352941177 - nodes in this community are weakly interconnected._
- **Should `test-population.R` be split into smaller, more focused modules?**
  _Cohesion score 0.125 - nodes in this community are weakly interconnected._