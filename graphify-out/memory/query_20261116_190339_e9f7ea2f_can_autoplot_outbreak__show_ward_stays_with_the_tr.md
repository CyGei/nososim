---
type: "query"
date: "2026-11-16T19:03:39.176636+00:00"
question: "Can autoplot(outbreak) show ward stays with the transmission tree overlaid?"
contributor: "graphify"
outcome: "useful"
source_nodes: ["autoplot.nososim_population()", "population_positions()", "make_outbreak()"]
---

# Q: Can autoplot(outbreak) show ward stays with the transmission tree overlaid?

## Answer

Query terms drawn from graph labels: autoplot, population, positions, outbreak. Proposed design: add autoplot.nososim_outbreak as a small wrapper around autoplot(object$population, mapping). Reuse the plotted data with labels, t, and .y to join object$infections by from/date and to/date. Draw arrows between source and recipient slots on the transmission date, and points for infection events including imported cases. Match labels plus date because slots are reused across episodes. Existing population plotting and outbreak simulation need no redesign. Source: R/autoplot.R, R/outbreak.R, and the same date-specific endpoint join pattern in R/count_edges.R. Proposal only; no implementation requested explicitly or made.

## Outcome

- Signal: useful

## Source Nodes

- autoplot.nososim_population()
- population_positions()
- make_outbreak()