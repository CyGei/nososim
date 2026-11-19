---
type: "query"
date: "2026-11-17T17:10:58.792733+00:00"
question: "How should plot_sankey support generic by = c(xxx, yyy, zzz) hierarchies with clear interpretation?"
contributor: "graphify"
outcome: "useful"
source_nodes: ["plot_sankey()", "sankey_layout()", "count_edges()"]
---

# Q: How should plot_sankey support generic by = c(xxx, yyy, zzz) hierarchies with clear interpretation?

## Answer

Implemented layout=nested for two full-group endpoint columns and layout=hierarchy for cumulative prefixes source xxx -> xxx/yyy -> xxx/yyy/zzz -> recipient xxx/yyy/zzz -> xxx/yyy -> xxx. Prefix IDs use original values so repeated child labels under different parents never merge. ggalluvial retains each full source-recipient count across all axes; custom lode guidance keeps outer branches uncrossed. Widths and node totals count transmission events, not distinct infectors or rates; only the central link is transmission. Colours identify the first varying source attribute. In the local example there are 38 transmissions: source A20 (patients12/staff8) and B18 (patients16/staff2); destination A17 and B21. All package tests pass.

## Outcome

- Signal: useful

## Source Nodes

- plot_sankey()
- sankey_layout()
- count_edges()