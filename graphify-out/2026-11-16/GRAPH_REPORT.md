# Graph Report - nososim  (2026-11-16)

## Corpus Check
- 59 files · ~23,223 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 22 file(s) not represented in the graph (top: .Rd 11, (none) 8, .Rmd 2)

## Summary
- 343 nodes · 292 edges · 61 communities (42 shown, 19 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `916c7be2`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- test-make_outbreak.R
- make_outbreak
- Q: Implement arrivals(data, t) with available in data, and clarify whether update can apply any rule checked at time t.
- draft.R
- autoplot.nososim_population
- examples/outbreak.R
- count_edges
- test-autoplot.R
- Graphify knowledge graph
- R-CMD-check workflow
- Cyril Geismar
- Q: Restore the nested landscape stay plot for autoplot using the current make_population output, keeping code concise.
- test-get_contacts.R
- Q: Explain the link between reduction and intervention and whether the code can be simplified in tidy R.
- Q: Can you do a complete analysis of the current codebase.
- Q: Use one concise consistent sampler interface for population generation.
- nososim_validation.qmd
- Q: How should make_population connect before and during make_outbreak with the smallest elegant R API?
- test-count_edges.R
- Q: Which existing nososim conventions should guide a landscape API?
- Q: Review the current code against main and suggest a very concise simple landscape and population implementation matching the whiteboard.
- Q: What is the best architecture for generating people through time from the current landscape, with location-specific admissions, lengths of stay and dynamically drawn attributes?
- test-landscape.R
- Q: Focus only on make_landscape from the vignette nested hospital/ward/room list and remove unnecessary experimental population and timeline changes.
- nososim
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
- test-get_contacts-weights.R
- Q: Review the suggestions for strictly minimal requirements and provide the final API from A to Z.
- Q: Independently review the minimal proposed API and use infection dates from simulate_outbreak_step instead of newly_infected.
- Q: Why did make_outbreak become complicated, and how can landscape -> population -> outbreak be simplified around a final population on entry?
- Q: Can we simplify the population and outbreak workflow while retaining attributes and stays that change during the outbreak?
- Q: Implement and independently assess a simpler dynamic simulation while retaining the patient and staff vignette as reference.
- Q: Summarise current nososim functions and workflow, compare with the previous commit, and recommend the simplest clear maintainable user API.
- Q: Do you see any similar improvements we could do in admit_individuals()?
- Q: Is outbreak.R the cleanest, simplest, most readable code with as much pipe use and as few non-tidy operations and intermediate objects as possible?
- Q: Can autoplot(outbreak) show ward stays with the transmission tree overlaid?
- Q: Implement autoplot(outbreak) with individual colours and fixed rows throughout consecutive stays.

## God Nodes (most connected - your core abstractions)
1. `autoplot.nososim_population()` - 11 edges
2. `make_outbreak()` - 11 edges
3. `autoplot.nososim_outbreak()` - 8 edges
4. `population_positions()` - 8 edges
5. `admit_individuals()` - 8 edges
6. `count_edges()` - 6 edges
7. `get_contacts()` - 6 edges
8. `collect()` - 5 edges
9. `Q: Which existing nososim conventions should guide a landscape API?` - 4 edges
10. `Q: How does our current landscape, timeline and population generation compare with an arrivals-driven, capacity-constrained hospital ward model, and what is the simplest clear robust generic approach?` - 4 edges

## Surprising Connections (you probably didn't know these)
- `population_positions()` --calls--> `tibble::as_tibble()`  [EXTRACTED]
  R/autoplot.R →   _Bridges community 4 → community 1_
- `get_contacts()` --calls--> `tibble::as_tibble()`  [EXTRACTED]
  R/get_contacts.R →   _Bridges community 1 → community 6_
- `make_outbreak()` --calls--> `rlang::is_named()`  [EXTRACTED]
  R/outbreak.R →   _Bridges community 8 → community 1_

## Import Cycles
- None detected.

## Communities (61 total, 19 thin omitted)

### Community 0 - "test-make_outbreak.R"
Cohesion: 0.08
Nodes (20): available_each_day, C, date, dates, expected, history, labels, model (+12 more)

### Community 1 - "make_outbreak"
Cohesion: 0.11
Nodes (5): align_contacts(), make_outbreak(), admit_individuals(), check_attributes(), make_population()

### Community 2 - "Q: Implement arrivals(data, t) with available in data, and clarify whether update can apply any rule checked at time t."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Implement arrivals(data, t) with available in data, and clarify whether update can apply any rule checked at time t., Source Nodes

### Community 3 - "draft.R"
Cohesion: 0.22
Nodes (4): outbreak, role_weights, start, ward_weights

### Community 4 - "autoplot.nososim_population"
Cohesion: 0.09
Nodes (3): autoplot.nososim_outbreak(), autoplot.nososim_population(), population_positions()

### Community 6 - "count_edges"
Cohesion: 0.17
Nodes (4): count_edges(), add_attributes(), get_contacts(), pairwise_contacts()

### Community 8 - "test-autoplot.R"
Cohesion: 0.08
Nodes (16): make_landscape(), collect(), mixing_matrix(), offspring(), combined, episodes, landscape, layers (+8 more)

### Community 14 - "Q: Restore the nested landscape stay plot for autoplot using the current make_population output, keeping code concise."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Restore the nested landscape stay plot for autoplot using the current make_population output, keeping code concise., Source Nodes

### Community 15 - "test-get_contacts.R"
Cohesion: 0.40
Nodes (4): contacts, data, expected, result

### Community 19 - "Q: Explain the link between reduction and intervention and whether the code can be simplified in tidy R."
Cohesion: 0.50
Nodes (3): Answer, Q: Explain the link between reduction and intervention and whether the code can be simplified in tidy R., Source Nodes

### Community 20 - "Q: Can you do a complete analysis of the current codebase."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Can you do a complete analysis of the current codebase., Source Nodes

### Community 21 - "Q: Use one concise consistent sampler interface for population generation."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Use one concise consistent sampler interface for population generation., Source Nodes

### Community 22 - "nososim_validation.qmd"
Cohesion: 0.33
Nodes (5): Add a scenario: block ward A → ward B, Checks and figures, Outputs, Scenarios, Simulation

### Community 23 - "Q: How should make_population connect before and during make_outbreak with the smallest elegant R API?"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: How should make_population connect before and during make_outbreak with the smallest elegant R API?, Source Nodes

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

### Community 31 - "Q: Focus only on make_landscape from the vignette nested hospital/ward/room list and remove unnecessary experimental population and timeline changes."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Focus only on make_landscape from the vignette nested hospital/ward/room list and remove unnecessary experimental population and timeline changes., Source Nodes

### Community 32 - "nososim"
Cohesion: 0.50
Nodes (3): A first outbreak, Installation, nososim

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
Nodes (10): arrivals, dates, generated, history, landscape, model, outbreak, population (+2 more)

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

### Community 46 - "test-get_contacts-weights.R"
Cohesion: 0.25
Nodes (6): data, expected, matched, reordered, reversed, weights

### Community 49 - "Q: Review the suggestions for strictly minimal requirements and provide the final API from A to Z."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Review the suggestions for strictly minimal requirements and provide the final API from A to Z., Source Nodes

### Community 50 - "Q: Independently review the minimal proposed API and use infection dates from simulate_outbreak_step instead of newly_infected."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Independently review the minimal proposed API and use infection dates from simulate_outbreak_step instead of newly_infected., Source Nodes

### Community 53 - "Q: Why did make_outbreak become complicated, and how can landscape -> population -> outbreak be simplified around a final population on entry?"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Why did make_outbreak become complicated, and how can landscape -> population -> outbreak be simplified around a final population on entry?, Source Nodes

### Community 54 - "Q: Can we simplify the population and outbreak workflow while retaining attributes and stays that change during the outbreak?"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Can we simplify the population and outbreak workflow while retaining attributes and stays that change during the outbreak?, Source Nodes

### Community 55 - "Q: Implement and independently assess a simpler dynamic simulation while retaining the patient and staff vignette as reference."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Implement and independently assess a simpler dynamic simulation while retaining the patient and staff vignette as reference., Source Nodes

### Community 56 - "Q: Summarise current nososim functions and workflow, compare with the previous commit, and recommend the simplest clear maintainable user API."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Summarise current nososim functions and workflow, compare with the previous commit, and recommend the simplest clear maintainable user API., Source Nodes

### Community 57 - "Q: Do you see any similar improvements we could do in admit_individuals()?"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Do you see any similar improvements we could do in admit_individuals()?, Source Nodes

### Community 58 - "Q: Is outbreak.R the cleanest, simplest, most readable code with as much pipe use and as few non-tidy operations and intermediate objects as possible?"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Is outbreak.R the cleanest, simplest, most readable code with as much pipe use and as few non-tidy operations and intermediate objects as possible?, Source Nodes

### Community 59 - "Q: Can autoplot(outbreak) show ward stays with the transmission tree overlaid?"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Can autoplot(outbreak) show ward stays with the transmission tree overlaid?, Source Nodes

### Community 60 - "Q: Implement autoplot(outbreak) with individual colours and fixed rows throughout consecutive stays."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Implement autoplot(outbreak) with individual colours and fixed rows throughout consecutive stays., Source Nodes

## Knowledge Gaps
- **4 isolated node(s):** `R-CMD-check workflow`, `R package check`, `Cyril Geismar`, `MIT License`
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 272 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **19 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Work-memory lessons

**Preferred sources** — corroborated by past sessions; start here.
- `admit_individuals()` (4× useful, score=3.962775373)
- `update_population()` (3× useful, score=2.947868968)

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `make_outbreak()` connect `make_outbreak` to `test-autoplot.R`?**
  _High betweenness centrality (0.033) - this node is a cross-community bridge._
- **What connects `R-CMD-check workflow`, `R package check`, `Cyril Geismar` to the rest of the system?**
  _4 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `test-make_outbreak.R` be split into smaller, more focused modules?**
  _Cohesion score 0.08333333333333333 - nodes in this community are weakly interconnected._
- **Why does `population_positions()` connect `autoplot.nososim_population` to `make_outbreak`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **Should `make_outbreak` be split into smaller, more focused modules?**
  _Cohesion score 0.10822510822510822 - nodes in this community are weakly interconnected._
- **Should `autoplot.nososim_population` be split into smaller, more focused modules?**
  _Cohesion score 0.09057971014492754 - nodes in this community are weakly interconnected._
- **Should `test-autoplot.R` be split into smaller, more focused modules?**
  _Cohesion score 0.08 - nodes in this community are weakly interconnected._