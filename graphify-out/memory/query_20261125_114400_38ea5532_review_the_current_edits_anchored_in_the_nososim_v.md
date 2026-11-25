---
type: "query"
date: "2026-11-25T11:44:00.493995+00:00"
question: "Review the current edits anchored in the nososim vignette for a coherent and consistent API workflow."
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_population()", "make_outbreak()", "get_contacts()", "get_intervention()", "sample_contacts()"]
---

# Q: Review the current edits anchored in the nososim vignette for a coherent and consistent API workflow.

## Answer

Reviewed make_population, make_outbreak, get_contacts, get_intervention and sample_contacts against the vignette. Callbacks consistently use data and t; matrices use source rows and recipient columns. Clarified C times E after optional sampling, daily callback order, snapshot timing and readmission persistence. Added sample_contacts help and reference entry; made multiplier comparison deterministic and removed development-only loading and redundant examples. All 192 test expectations passed and the vignette rendered.

## Outcome

- Signal: useful

## Source Nodes

- make_population()
- make_outbreak()
- get_contacts()
- get_intervention()
- sample_contacts()