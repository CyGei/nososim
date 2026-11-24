---
type: "query"
date: "2026-11-24T14:16:58.937832+00:00"
question: "What would Poisson and multinomial stochastic contact generation mean in this code?"
contributor: "graphify"
outcome: "useful"
source_nodes: ["get_contacts()"]
---

# Q: What would Poisson and multinomial stochastic contact generation mean in this code?

## Answer

Query terms: contacts, multipliers, transmission. Verified R/get_contacts.R:35-61 builds deterministic allowed-pair weights. R/outbreak.R:140 invokes contacts daily and passes C separately from tau and w at lines 147-157. Proposed, not implemented: keep get_contacts as expected rates, sample each positive row total with Poisson and allocate using multinomial, preserving labels and zero rows. Wrap this sampler in vignette contacts callback. Counts are directed, may repeat recipients, and require a daily baseline scale if multipliers are relative.

## Outcome

- Signal: useful

## Source Nodes

- get_contacts()