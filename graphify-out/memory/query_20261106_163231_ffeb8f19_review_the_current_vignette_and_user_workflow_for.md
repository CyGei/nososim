---
type: "query"
date: "2026-11-06T16:32:31.973291+00:00"
question: "Review the current vignette and user workflow for API cleanliness: are admissions columns defaults, or are location columns and admission/individual functions user defined?"
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_population()", "make_landscape()", "make_timeline()"]
---

# Q: Review the current vignette and user workflow for API cleanliness: are admissions columns defaults, or are location columns and admission/individual functions user defined?

## Answer

Read-only review of current sources and docs. R/population.R requires n in locations and reserves id/location/admission/los/discharge; it does not read or require admission_rate. Other location columns are user metadata passed to callbacks and copied to individual records. Both admissions and individuals are mandatory user functions, with fixed contracts: counts per location in row order, and preserved admitted rows plus positive integer los. The vignette makes optional admission_rate feel like schema by giving it its own Define admission rates step. Recommendation: retain the simple API, show a minimal example without rate columns first, then describe optional location-varying parameters added using mutate, with sampling/time logic in callbacks. Explain that parameter names are chosen by users and only their callbacks interpret them. Mark output structural fields and los as the small package contract. Also found README.Rmd still teaches make_timeline as the population entry point while vignette uses make_population; align documentation around one primary workflow later. Current callback flexibility is location/date based; admissions receives no occupancy/free state, so vacancy-aware custom rules would require explicit runtime context if needed. No source or vignette changes were made during this review.

## Outcome

- Signal: useful

## Source Nodes

- make_population()
- make_landscape()
- make_timeline()