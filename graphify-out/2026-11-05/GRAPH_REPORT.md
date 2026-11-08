# Graph Report - nososim  (2026-11-05)

## Corpus Check
- 29 files · ~17,749 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 23 file(s) not represented in the graph (top: .Rd 12, (none) 8, .Rmd 2)

## Summary
- 231 nodes · 219 edges · 32 communities (16 shown, 16 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `0c5059d3`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- test-make_outbreak.R
- autoplot.nososim_timeline
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
- landscape.R
- nososim_validation.qmd
- timeline.R
- test-count_edges.R
- Q: Which existing nososim conventions should guide a landscape API?
- test-population.R
- test-landscape-timeline.R

## God Nodes (most connected - your core abstractions)
1. `as_daily()` - 7 edges
2. `autoplot.nososim_timeline()` - 6 edges
3. `count_edges()` - 6 edges
4. `make_timeline()` - 5 edges
5. `check_stays()` - 5 edges
6. `Pairwise infection hazard` - 5 edges
7. `location_positions()` - 4 edges
8. `autoplot.nososim_outbreak()` - 4 edges
9. `make_outbreak()` - 4 edges
10. `check_timeline()` - 4 edges

## Surprising Connections (you probably didn't know these)
- `make_timeline()` --calls--> `tidyr::uncount()`  [EXTRACTED]
  R/timeline.R →   _Bridges community 1 → community 23_
- `make_landscape()` --calls--> `tibble::as_tibble()`  [EXTRACTED]
  dev/landscape.R →   _Bridges community 1 → community 21_
- `count_edges()` --calls--> `dplyr::count()`  [EXTRACTED]
  R/count_edges.R →   _Bridges community 6 → community 23_

## Import Cycles
- None detected.

## Communities (32 total, 16 thin omitted)

### Community 0 - "test-make_outbreak.R"
Cohesion: 0.07
Nodes (23): offspring(), fixed_population(), simple_outbreak(), blocked, excluded, expected, hazard_fixture(), imported (+15 more)

### Community 1 - "autoplot.nososim_timeline"
Cohesion: 0.11
Nodes (8): autoplot.nososim_outbreak(), autoplot.nososim_timeline(), location_positions(), make_outbreak(), mixing_matrix(), transmission_hazards(), location_capacities(), make_population()

### Community 2 - "Pairwise infection hazard"
Cohesion: 0.16
Nodes (10): Baseline daily infectiousness, Baseline reproduction number, Daily transmission simulation, Diffusion matrices, Generation time PMF, Time-varying intervention matrix, Pairwise diffusion weights, Pairwise infection hazard (+2 more)

### Community 3 - "draft.R"
Cohesion: 0.20
Nodes (6): dates, outbreak, role_weights, start, timeline, ward_weights

### Community 4 - "test-timeline.R"
Cohesion: 0.10
Nodes (19): a, b, daily, date, dates, empty, expected, landscape (+11 more)

### Community 5 - "examples/outbreak.R"
Cohesion: 0.18
Nodes (6): dates, imported, outbreak, population, stays, timeline

### Community 8 - "test-autoplot.R"
Cohesion: 0.12
Nodes (14): a, b, built, dates, landscape, layers, links, outbreak (+6 more)

### Community 19 - "Q: Explain the link between reduction and intervention and whether the code can be simplified in tidy R."
Cohesion: 0.50
Nodes (3): Answer, Q: Explain the link between reduction and intervention and whether the code can be simplified in tidy R., Source Nodes

### Community 20 - "nososim"
Cohesion: 0.40
Nodes (4): A first outbreak, Go further, Installation, nososim

### Community 21 - "landscape.R"
Cohesion: 0.15
Nodes (10): Hmat, hospitals, landscape, locations, make_landscape(), flatten(), rooms, rooms_per_ward (+2 more)

### Community 22 - "nososim_validation.qmd"
Cohesion: 0.33
Nodes (5): Add a scenario: block ward A → ward B, Checks and figures, Outputs, Scenarios, Simulation

### Community 23 - "timeline.R"
Cohesion: 0.16
Nodes (7): as_daily(), check_stays(), check_timeline(), draw(), make_timeline(), new_timeline(), set_attribute()

### Community 24 - "test-count_edges.R"
Cohesion: 0.20
Nodes (9): aggregated, columns, daily, date, dates, empty, joint, outbreak (+1 more)

### Community 27 - "Q: Which existing nososim conventions should guide a landscape API?"
Cohesion: 0.40
Nodes (4): Answer, Outcome, Q: Which existing nososim conventions should guide a landscape API?, Source Nodes

### Community 28 - "test-population.R"
Cohesion: 0.25
Nodes (7): a, attributes, b, daily, dates, population, stays

### Community 29 - "test-landscape-timeline.R"
Cohesion: 0.17
Nodes (11): date, edited, empty, landscape, original, other, population, scheduled (+3 more)

## Knowledge Gaps
- **9 isolated node(s):** `R-CMD-check workflow`, `R package check`, `Cyril Geismar`, `MIT License`, `Baseline reproduction number` (+4 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 171 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **16 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `as_daily()` connect `timeline.R` to `autoplot.nososim_timeline`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **What connects `R-CMD-check workflow`, `R package check`, `Cyril Geismar` to the rest of the system?**
  _9 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `test-make_outbreak.R` be split into smaller, more focused modules?**
  _Cohesion score 0.07142857142857142 - nodes in this community are weakly interconnected._
- **Why does `make_landscape()` connect `landscape.R` to `autoplot.nososim_timeline`?**
  _High betweenness centrality (0.022) - this node is a cross-community bridge._
- **Should `autoplot.nososim_timeline` be split into smaller, more focused modules?**
  _Cohesion score 0.1067193675889328 - nodes in this community are weakly interconnected._
- **Should `test-timeline.R` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._
- **Should `test-autoplot.R` be split into smaller, more focused modules?**
  _Cohesion score 0.125 - nodes in this community are weakly interconnected._