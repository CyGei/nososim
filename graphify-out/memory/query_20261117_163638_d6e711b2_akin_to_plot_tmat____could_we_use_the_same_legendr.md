---
type: "query"
date: "2026-11-17T16:36:38.910791+00:00"
question: "Akin to plot_tmat(), could we use the same legendry::guide_axis_nested architecture to make a sankey plot?"
contributor: "graphify"
outcome: "useful"
source_nodes: ["plot_tmat()", "legendry::guide_axis_nested()"]
---

# Q: Akin to plot_tmat(), could we use the same legendry::guide_axis_nested architecture to make a sankey plot?

## Answer

Inspected graph nodes plot_tmat and legendry::guide_axis_nested and verified R/plot_tmat.R. Proposed design: share count_edges, ordered population group lookup, and nested attribute hierarchy; lay out source and recipient stacks separately with ribbon widths proportional to transmissions. Use continuous vertical coordinates and guide_axis_nested with key_range_manual for exact group bounds on left and right axes; legendry official documentation confirms continuous manual ranged keys. This is a design proposal, not an implemented Sankey function. Zero-flow groups need an explicit display policy.

## Outcome

- Signal: useful

## Source Nodes

- plot_tmat()
- legendry::guide_axis_nested()