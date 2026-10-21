---
type: "query"
date: "2026-10-21T17:42:41.701521+00:00"
question: "Explain the link between reduction and intervention and whether the code can be simplified in tidy R."
contributor: "graphify"
source_nodes: ["make_outbreak()", "transmission_hazards()"]
---

# Q: Explain the link between reduction and intervention and whether the code can be simplified in tidy R.

## Answer

Graph confirms make_outbreak() calls transmission_hazards() at R/make_outbreak.R:L89. Direct source inspection at L87-L89 shows reduction is the matrix returned by intervention(date, present). At L183-L191 the matrix is aligned by IDs and applied as 1 - reduction after mixing normalization. Recommend clearer name hazard_reduction and retaining vectorized matrix arithmetic and validation. The intervention examples at L35-L47 need a final E expression to return their matrix. No source code changed.

## Source Nodes

- make_outbreak()
- transmission_hazards()