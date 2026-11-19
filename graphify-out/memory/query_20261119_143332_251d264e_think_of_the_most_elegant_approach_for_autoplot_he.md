---
type: "query"
date: "2026-11-19T14:33:32.580547+00:00"
question: "Think of the most elegant approach for autoplot here? Should population be a shape aes and their label a label aes?"
contributor: "graphify"
outcome: "useful"
source_nodes: ["autoplot.nososim_outbreak()", "population_positions()"]
---

# Q: Think of the most elegant approach for autoplot here? Should population be a shape aes and their label a label aes?

## Answer

Design proposal, not implemented: keep one public mapping argument; default colour=labels and shape=population, with optional label=labels activating an infection-node text layer. Join infection recipients to their full daily population snapshot using to=labels and date=t, retaining labels and metadata. Apply colour to stays and nodes, shape to points, label to text; edges remain independently mapped. Current R/autoplot.R:77 retains only labels,t,.y, and :103 hardcodes shape to import/local. Replace the import/local shape scale if population controls shape; imports remain identifiable as roots without incoming arrows. Preserve source infection-date endpoints. User requested design discussion only.

## Outcome

- Signal: useful

## Source Nodes

- autoplot.nososim_outbreak()
- population_positions()