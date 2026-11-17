---
type: "query"
date: "2026-11-16T19:12:10.879733+00:00"
question: "Implement autoplot(outbreak) with individual colours and fixed rows throughout consecutive stays."
contributor: "graphify"
outcome: "useful"
source_nodes: ["autoplot.nososim_outbreak()", "autoplot.nososim_population()", "population_positions()"]
---

# Q: Implement autoplot(outbreak) with individual colours and fixed rows throughout consecutive stays.

## Answer

Implemented autoplot.nososim_outbreak in R/autoplot.R, registered and documented. It reuses the population plot and joins from/to plus date to plotted daily positions. Curved arrows show local transmissions; diamonds mark imports and circles local infections. Both autoplot methods default to colour=labels, hiding the label legend; custom mappings remain available. Existing per-stay slot allocation is retained and tested through turnover and readmission into another ward. All 30 plotting assertions pass; full suite has 158 passing assertions and one unrelated failure for zero-weight PMF rejection. Rendered and inspected the outbreak example. Graph vocabulary: autoplot, population, positions, outbreak.

## Outcome

- Signal: useful

## Source Nodes

- autoplot.nososim_outbreak()
- autoplot.nososim_population()
- population_positions()