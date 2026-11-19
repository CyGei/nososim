---
type: "query"
date: "2026-11-05T18:46:08.149800+00:00"
question: "How does our current landscape, timeline and population generation compare with an arrivals-driven, capacity-constrained hospital ward model, and what is the simplest clear robust generic approach?"
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_timeline()", "make_population()", "sample_stays()", "as_daily()"]
---

# Q: How does our current landscape, timeline and population generation compare with an arrivals-driven, capacity-constrained hospital ward model, and what is the simplest clear robust generic approach?

## Answer

Expanded from original query via graph vocabulary: [landscape, population, timeline, admission, discharge, allocation, stays]. The graph located make_population(), the landscape development script and integration tests; direct source inspection supplied the details missing from its R call graph.

The proposed arrivals-first model is a clearer primary model for hospital patient flow, while the existing bed-turnover model remains a simpler synthetic occupancy generator. Both are conditional on the landscape; the distinction is what drives admissions.

Current working-tree flow: a named nested landscape has capacities at its leaves (R/population.R:48). make_timeline expands each location into places and generates independent successive stays and vacancy gaps for each place (R/timeline.R:23-44). sample_stays initialises each bed in equilibrium, including length-biased initial intervals and uniformly sampled elapsed duration (R/timeline.R:49-72). make_population creates a new individual per stay, then evaluates attribute generators in sequence (R/population.R:23-44). as_daily expands stays into person-days and make_outbreak consumes that daily attendance (R/timeline.R:88-108; R/make_outbreak.R:69-108). The separate make_landscape constructor in dev/landscape.R is experimental, not the exported production input.

With gap zero, every place is occupied continuously and a discharge is followed immediately by a replacement. With positive gaps, the equilibrium occupied fraction is mean(stay)/(mean(stay)+mean(gap)). Thus 200 beds with stay nine and gap one have expected occupancy 180, with a random actual day-zero count. There is no independent arrival stream, queue, or record of excess demand. Attributes are generated after stay duration and location have already been determined.

Recommendation: retain the fixed landscape, people table and linked stay intervals; use an arrivals-driven generator to generate people and allocate their stays jointly. Daily attendance remains a derived view feeding the current outbreak engine. A small daily stateful loop is sufficient at the existing daily resolution; a full continuous-time DES engine is only warranted if within-day timing or more complex queues matter. On each day release beds with end <= day, obtain arrivals and characteristics, assign eligible free beds, schedule discharge as admitted date plus sampled LOS, record unallocated arrivals and derive occupancy. A patient's planned discharge follows from LOS and should not be independently sampled again.

Keep end dates exclusive. Define explicit overflow handling and distinguish arrival demand from actual admission counts. Observed admission counts generally represent realised entries; they should not automatically be interpreted as unconstrained demand when changing capacity. Initial 90 percent occupancy is an initial condition, not a guarantee of future occupancy. Preserve equilibrium residual-LOS sampling for hypothetical initial patients or condition total LOS on the elapsed stay for observed inpatients. Permit location and patient attributes to determine LOS and eligibility. Staff attendance is a separate generating process that can share the daily output format; staff should not automatically consume patient beds. Keep person ID distinct from stay ID so transfers or readmissions can eventually share an identity, which the current one-person-per-stay generator does not provide.

Validation: devtools::test(filter = "^(timeline|population|landscape-timeline)$", reporter = "summary") passed. No package code was changed. External primary sources checked: simmer author documentation on arrival sources, finite resources and event ordering; Garcia-Vicuna et al. (2023), PLOS ONE, doi:10.1371/journal.pone.0282331, section 3.4 on conditional remaining length of stay for existing patients.

## Outcome

- Signal: useful

## Source Nodes

- make_timeline()
- make_population()
- sample_stays()
- as_daily()