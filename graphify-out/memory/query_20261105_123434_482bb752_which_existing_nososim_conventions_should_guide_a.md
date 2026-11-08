---
type: "query"
date: "2026-11-05T12:34:34.269644+00:00"
question: "Which existing nososim conventions should guide a landscape API?"
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_outbreak()", "mixing_matrix()", "transmission_hazards()"]
---

# Q: Which existing nososim conventions should guide a landscape API?

## Answer

Expanded graph vocabulary: make timeline mixing matrix weights tibble. Graph identified make_outbreak(), mixing_matrix() at R/make_outbreak.R:L165 and transmission_hazards() at L192. Source inspection confirms tidyverse pipelines, lightweight S3 list output, source-row recipient-column matrices, multiplication across attributes, and per-source normalisation after excluding self-contact. Proposed landscape API remains a design recommendation, not implemented code.

## Outcome

- Signal: useful

## Source Nodes

- make_outbreak()
- mixing_matrix()
- transmission_hazards()