---
type: "query"
date: "2026-11-06T15:19:16.169525+00:00"
question: "Focus only on make_landscape from the vignette nested hospital/ward/room list and remove unnecessary experimental population and timeline changes."
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_landscape()"]
---

# Q: Focus only on make_landscape from the vignette nested hospital/ward/room list and remove unnecessary experimental population and timeline changes.

## Answer

User explicitly narrowed scope to the landscape and asked to remove unnecessary code and edits. Backed up pre-cleanup tracked changes and untracked source files to /tmp/nososim-before-landscape-1ysrcdb8. Rolled back experimental population, turnover, plotting, examples and downstream edits to main while preserving the existing summary-method removal and its print/documentation adjustments. Removed R/population.R and duplicate dev/landscape.R prototypes plus dependent new docs/tests. Implemented R/landscape.R make_landscape(landscape): validate a nonempty named hierarchy with unique sibling names and finite nonnegative whole capacities; flatten to one terminal-location row with location_1, location_2, etc and capacity, retaining input order and zero-capacity leaves. No extra class or parallel stored representations. Vignette now stops at the supplied nested landscape, its table, and aggregate ward capacities. The supplied example has ten rooms and twenty-seven places. Tests pass including hierarchy, uneven depths, zero capacities and invalid inputs; vignette rendered; graphify update . completed with external-node source metadata warnings. Population and admission API design is deferred until the user resumes that step.

## Outcome

- Signal: useful

## Source Nodes

- make_landscape()