---
type: "query"
date: "2026-11-06T10:03:04.379419+00:00"
question: "Use one concise consistent sampler interface for population generation."
contributor: "graphify"
outcome: "corrected"
correction: "The current API uses admissions=function(n), not admission_rate or function(date). All three stay/admission inputs are sampler-only. Initial remaining stays are explicit; numeric/vector shortcuts and automatic initial residuals have been removed."
source_nodes: ["make_population()", "location_rules()", "sample_population()"]
---

# Q: Use one concise consistent sampler interface for population generation.

## Answer

Simplified R/population.R: admissions, los and initial_los now accept only function(n) samplers or identically structured location lists. admissions replaces admission_rate and returns one count per post-census day in a single call. LOS and remaining LOS return positive integer days. Removed scalar/vector shortcuts, implicit initial residual sampling and the precomputed-stay overload. Initial remaining stays are explicit for occupied locations. Reduced population.R from 295 to 216 lines and shortened documentation. Full tests and rendered examples pass; R CMD check has zero errors, warnings and notes. Expanded graph vocabulary: population, admissions, timeline, location, rules.

## Outcome

- Signal: corrected
- Correction: The current API uses admissions=function(n), not admission_rate or function(date). All three stay/admission inputs are sampler-only. Initial remaining stays are explicit; numeric/vector shortcuts and automatic initial residuals have been removed.

## Source Nodes

- make_population()
- location_rules()
- sample_population()