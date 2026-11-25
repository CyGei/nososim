# Graph Report - nososim  (2026-11-25)

## Corpus Check
- 78 files · ~26,726 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 24 file(s) not represented in the graph (top: .Rd 13, (none) 8, .Rmd 2)

## Summary
- 456 nodes · 406 edges · 77 communities (54 shown, 23 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `8f69e84a`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- test-make_outbreak.R
- make_outbreak
- Q: Implement arrivals(data, t) with available in data, and clarify whether update can apply any rule checked at time t.
- draft.R
- plot_sankey
- examples/outbreak.R
- transmission_groups
- test-plot_sankey.R
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
- test-get_contacts-multipliers.R
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
- test-autoplot.R
- Q: Why does the transmission overlay look disconnected? Dots should be at infection dates.
- Q: Audit with agents the codebase and evaluate how easy it is for a new user to understand the code and use the API.
- Q: What would Poisson and multinomial stochastic contact generation mean in this code?
- Q: Akin to plot_tmat(), could we use the same legendry::guide_axis_nested architecture to make a sankey plot?
- Q: How should plot_sankey support generic by = c(xxx, yyy, zzz) hierarchies with clear interpretation?
- autoplot.nososim_outbreak
- Q: Think of the most elegant approach for autoplot here? Should population be a shape aes and their label a label aes?
- Q: Keep nodes white, colour timelines, shape nodes, label nodes, and preserve default aes.
- test-sample_contacts.R
- sample_contacts
- test-intervention.R
- test-get_intervention.R
- Q: Trace the current nososim and Simulacres contact-to-infection path and plan vaccination, isolation, cohorting and masks using source i and recipient j.

## God Nodes (most connected - your core abstractions)
1. `autoplot.nososim_outbreak()` - 16 edges
2. `plot_sankey()` - 14 edges
3. `transmission_groups()` - 13 edges
4. `make_outbreak()` - 10 edges
5. `population_positions()` - 9 edges
6. `plot_tmat()` - 9 edges
7. `sankey_layout()` - 9 edges
8. `count_edges()` - 6 edges
9. `get_contacts()` - 6 edges
10. `admit_individuals()` - 6 edges

## Surprising Connections (you probably didn't know these)
- `autoplot.nososim_outbreak()` --calls--> `population_positions()`  [EXTRACTED]
  R/autoplot.R → R/autoplot.R  _Bridges community 68 → community 6_
- `autoplot.nososim_outbreak()` --calls--> `ggplot2::guides()`  [EXTRACTED]
  R/autoplot.R →   _Bridges community 68 → community 4_
- `get_contacts()` --calls--> `tibble::as_tibble()`  [EXTRACTED]
  R/get_contacts.R →   _Bridges community 6 → community 1_
- `collect()` --calls--> `tibble::tibble()`  [EXTRACTED]
  R/landscape.R →   _Bridges community 4 → community 61_
- `sankey_layout()` --calls--> `tibble::tibble()`  [EXTRACTED]
  R/sankey_layout.R →   _Bridges community 61 → community 6_

## Import Cycles
- None detected.

## Communities (77 total, 23 thin omitted)

### Community 0 - "test-make_outbreak.R"
Cohesion: 0.15
Nodes (12): contacts, date, dates, history, labels, model, outbreak, patient_history (+4 more)

### Community 1 - "make_outbreak"
Cohesion: 0.11
Nodes (4): align_pairwise(), make_outbreak(), admit_individuals(), make_population()

### Community 2 - "Q: Implement arrivals(data, t) with available in data, and clarify whether update can apply any rule checked at time t."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Implement arrivals(data, t) with available in data, and clarify whether update can apply any rule checked at time t., Source Nodes

### Community 3 - "draft.R"
Cohesion: 0.22
Nodes (4): outbreak, role_multipliers, start, ward_multipliers

### Community 4 - "plot_sankey"
Cohesion: 0.09
Nodes (5): make_landscape(), collect(), mixing_matrix(), plot_sankey(), sankey_axis()

### Community 6 - "transmission_groups"
Cohesion: 0.08
Nodes (8): population_positions(), count_edges(), add_attributes(), get_contacts(), pairwise_contacts(), sankey_layout(), transmission_groups(), endpoint()

### Community 8 - "test-plot_sankey.R"
Cohesion: 0.10
Nodes (19): built, by, drawing, flow, flows, inner, leaves, left (+11 more)

### Community 14 - "Q: Restore the nested landscape stay plot for autoplot using the current make_population output, keeping code concise."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Restore the nested landscape stay plot for autoplot using the current make_population output, keeping code concise., Source Nodes

### Community 15 - "test-get_contacts.R"
Cohesion: 0.40
Nodes (3): contacts, data, expected

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
Cohesion: 0.20
Nodes (8): arrivals, dates, generated, history, landscape, outbreak, population, supplied

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

### Community 46 - "test-get_contacts-multipliers.R"
Cohesion: 0.29
Nodes (5): data, expected, multipliers, reordered, reversed

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

### Community 61 - "test-autoplot.R"
Cohesion: 0.08
Nodes (20): offspring(), data, edges, labelled, layers, outbreak, plot, plot_outbreak() (+12 more)

### Community 62 - "Q: Why does the transmission overlay look disconnected? Dots should be at infection dates."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Why does the transmission overlay look disconnected? Dots should be at infection dates., Source Nodes

### Community 63 - "Q: Audit with agents the codebase and evaluate how easy it is for a new user to understand the code and use the API."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Audit with agents the codebase and evaluate how easy it is for a new user to understand the code and use the API., Source Nodes

### Community 64 - "Q: What would Poisson and multinomial stochastic contact generation mean in this code?"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: What would Poisson and multinomial stochastic contact generation mean in this code?, Source Nodes

### Community 65 - "Q: Akin to plot_tmat(), could we use the same legendry::guide_axis_nested architecture to make a sankey plot?"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Akin to plot_tmat(), could we use the same legendry::guide_axis_nested architecture to make a sankey plot?, Source Nodes

### Community 66 - "Q: How should plot_sankey support generic by = c(xxx, yyy, zzz) hierarchies with clear interpretation?"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: How should plot_sankey support generic by = c(xxx, yyy, zzz) hierarchies with clear interpretation?, Source Nodes

### Community 68 - "autoplot.nososim_outbreak"
Cohesion: 0.10
Nodes (3): autoplot.nososim_outbreak(), plot_tmat(), axis()

### Community 69 - "Q: Think of the most elegant approach for autoplot here? Should population be a shape aes and their label a label aes?"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Think of the most elegant approach for autoplot here? Should population be a shape aes and their label a label aes?, Source Nodes

### Community 70 - "Q: Keep nodes white, colour timelines, shape nodes, label nodes, and preserve default aes."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Keep nodes white, colour timelines, shape nodes, label nodes, and preserve default aes., Source Nodes

### Community 71 - "test-sample_contacts.R"
Cohesion: 0.50
Nodes (3): average, C, n

### Community 74 - "test-intervention.R"
Cohesion: 0.14
Nodes (10): actual, baseline, dates, E, expected, labels, model, neutral (+2 more)

### Community 75 - "test-get_intervention.R"
Cohesion: 0.29
Nodes (6): data, effect, expected, multipliers, status, wards

### Community 76 - "Q: Trace the current nososim and Simulacres contact-to-infection path and plan vaccination, isolation, cohorting and masks using source i and recipient j."
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Trace the current nososim and Simulacres contact-to-infection path and plan vaccination, isolation, cohorting and masks using source i and recipient j., Source Nodes

## Knowledge Gaps
- **4 isolated node(s):** `R-CMD-check workflow`, `R package check`, `Cyril Geismar`, `MIT License`
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 350 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **23 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Work-memory lessons

**Preferred sources** — corroborated by past sessions; start here.
- `admit_individuals()` (4× useful, score=3.304909664)
- `population_positions()` (4× useful, score=3.248563124)
- `update_population()` (3× useful, score=2.458489246)

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `autoplot.nososim_outbreak()` connect `autoplot.nososim_outbreak` to `plot_sankey`, `transmission_groups`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **What connects `R-CMD-check workflow`, `R package check`, `Cyril Geismar` to the rest of the system?**
  _4 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `make_outbreak` be split into smaller, more focused modules?**
  _Cohesion score 0.11052631578947368 - nodes in this community are weakly interconnected._
- **Why does `transmission_groups()` connect `transmission_groups` to `test-autoplot.R`?**
  _High betweenness centrality (0.026) - this node is a cross-community bridge._
- **Should `plot_sankey` be split into smaller, more focused modules?**
  _Cohesion score 0.09057971014492754 - nodes in this community are weakly interconnected._
- **Why does `sankey_outbreak()` connect `test-autoplot.R` to `test-plot_sankey.R`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **Should `transmission_groups` be split into smaller, more focused modules?**
  _Cohesion score 0.07765151515151515 - nodes in this community are weakly interconnected._