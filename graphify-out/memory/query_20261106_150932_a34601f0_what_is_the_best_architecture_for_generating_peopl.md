---
type: "query"
date: "2026-11-06T15:09:32.987103+00:00"
question: "What is the best architecture for generating people through time from the current landscape, with location-specific admissions, lengths of stay and dynamically drawn attributes?"
contributor: "graphify"
outcome: "corrected"
correction: "The user clarified that population generation itself must be driven by availability through time and location-specific rules. Do not focus the architecture on splitting the main-branch individual-generation block from daily expansion; connect the current landscape object to one occupancy process, and generate attributes plus conditional LOS at admission."
source_nodes: ["make_landscape()", "make_population()", "populate_stays()", "make_timeline()", "as_daily()", "make_outbreak()"]
---

# Q: What is the best architecture for generating people through time from the current landscape, with location-specific admissions, lengths of stay and dynamically drawn attributes?

## Answer

Expanded graph terms: landscape, population, admissions, stays, attributes, location. Verified current branch: dev/landscape.R make_landscape() returns locations with id/parent/capacity plus mixing, whereas R/population.R still accepts raw nested capacities and reconstructs synthetic location IDs. Attributes are currently assigned after the full stay schedule, so they cannot inform stay duration. Recommendation: make_population() is the sole occupancy simulator consuming the existing landscape object. Each day release departures, draw admission counts once per chosen area, allocate free descendant places subject to capacity, and generate new individuals with their attributes and LOS together using the allocated-place/date context. Use simple callbacks returning tibbles rather than a second nested rule tree. Keep as_daily() as an optional expansion and retire make_timeline() as an independent turnover generator. Return person/stay records with IDs, location/place, admission/discharge and attributes. If epidemic events change LOS, run the same internal occupancy step alongside the outbreak loop instead of precomputing replacement admissions.

## Outcome

- Signal: corrected
- Correction: The user clarified that population generation itself must be driven by availability through time and location-specific rules. Do not focus the architecture on splitting the main-branch individual-generation block from daily expansion; connect the current landscape object to one occupancy process, and generate attributes plus conditional LOS at admission.

## Source Nodes

- make_landscape()
- make_population()
- populate_stays()
- make_timeline()
- as_daily()
- make_outbreak()