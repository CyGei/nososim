# Graph Report - nososim  (2026-10-21)

## Corpus Check
- 20 files · ~11,056 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 17 file(s) not represented in the graph (top: .Rd 9, (none) 6, .Rmd 2)

## Summary
- 127 nodes · 118 edges · 22 communities (11 shown, 11 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `dfefd10b`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- test-make_outbreak.R
- autoplot.nososim_outbreak
- Pairwise infection hazard
- draft.R
- test-timeline.R
- outbreak.R
- timeline.R
- test-summary.R
- test-autoplot.R
- Graphify knowledge graph
- R-CMD-check workflow
- Cyril Geismar
- Q: Explain the link between reduction and intervention and whether the code can be simplified in tidy R.
- nososim
- tibble::tibble

## God Nodes (most connected - your core abstractions)
1. `autoplot.nososim_outbreak()` - 5 edges
2. `Pairwise infection hazard` - 5 edges
3. `make_outbreak()` - 4 edges
4. `summary.nososim_timeline()` - 4 edges
5. `make_timeline()` - 4 edges
6. `nososim` - 4 edges
7. `Daily transmission simulation` - 4 edges
8. `Hazard-weighted source assignment` - 4 edges
9. `autoplot.nososim_timeline()` - 3 edges
10. `summary.nososim_outbreak()` - 3 edges

## Surprising Connections (you probably didn't know these)
- None detected - all connections are within the same source files.

## Import Cycles
- None detected.

## Communities (22 total, 11 thin omitted)

### Community 0 - "test-make_outbreak.R"
Cohesion: 0.10
Nodes (18): blocked, excluded, expected, initial, invalid, outbreak, patient, present (+10 more)

### Community 1 - "autoplot.nososim_outbreak"
Cohesion: 0.18
Nodes (7): autoplot.nososim_outbreak(), autoplot.nososim_timeline(), make_outbreak(), mixing_matrix(), transmission_hazards(), summary.nososim_outbreak(), summary.nososim_timeline()

### Community 2 - "Pairwise infection hazard"
Cohesion: 0.16
Nodes (10): Baseline daily infectiousness, Baseline reproduction number, Daily transmission simulation, Diffusion matrices, Generation time PMF, Time-varying intervention matrix, Pairwise diffusion weights, Pairwise infection hazard (+2 more)

### Community 3 - "draft.R"
Cohesion: 0.20
Nodes (6): dates, group_weights, outbreak, start, timeline, ward_weights

### Community 4 - "test-timeline.R"
Cohesion: 0.20
Nodes (9): dates, expected, monday, people, scheduled, start, timeline, updated (+1 more)

### Community 5 - "outbreak.R"
Cohesion: 0.22
Nodes (4): dates, initial, outbreak, timeline

### Community 6 - "timeline.R"
Cohesion: 0.32
Nodes (3): draw(), make_timeline(), new_timeline()

### Community 7 - "test-summary.R"
Cohesion: 0.33
Nodes (5): dates, outbreak, result, start, timeline

### Community 8 - "test-autoplot.R"
Cohesion: 0.33
Nodes (5): layers, outbreak, segments, start, timeline

### Community 19 - "Q: Explain the link between reduction and intervention and whether the code can be simplified in tidy R."
Cohesion: 0.50
Nodes (3): Answer, Q: Explain the link between reduction and intervention and whether the code can be simplified in tidy R., Source Nodes

### Community 20 - "nososim"
Cohesion: 0.40
Nodes (4): A first outbreak, Go further, Installation, nososim

## Knowledge Gaps
- **9 isolated node(s):** `R-CMD-check workflow`, `R package check`, `Cyril Geismar`, `MIT License`, `Baseline reproduction number` (+4 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 87 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **11 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `hazard_fixture()` connect `tibble::tibble` to `test-make_outbreak.R`?**
  _High betweenness centrality (0.008) - this node is a cross-community bridge._
- **What connects `R-CMD-check workflow`, `R package check`, `Cyril Geismar` to the rest of the system?**
  _9 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `test-make_outbreak.R` be split into smaller, more focused modules?**
  _Cohesion score 0.1 - nodes in this community are weakly interconnected._