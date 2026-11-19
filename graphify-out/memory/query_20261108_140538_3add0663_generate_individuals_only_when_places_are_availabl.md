---
type: "query"
date: "2026-11-08T14:05:38.940699+00:00"
question: "Generate individuals only when places are available; avoid computing rejected people while keeping user-defined complete records."
contributor: "graphify"
outcome: "corrected"
correction: "The user rejected generating complete candidate people before checking space. For this simulation, draw attempted counts, cap by available places, and generate complete user-defined individual records only for the admitted count. Keep minimal required location/start/end information for tracking, with all individual fields supplied by the user function. Do not implement the pre-generated request-table plus accepted/rejected-list proposal."
source_nodes: ["make_population()", "make_landscape()"]
---

# Q: Generate individuals only when places are available; avoid computing rejected people while keeping user-defined complete records.

## Answer

The user interrupted the planned request-table migration and clarified that only admissible individuals should be generated. The two-input offline allocation plan was not implemented. Retained make_population(locations, dates, admissions, individuals) as a chronological simulation, with a clearer contract: admissions supplies cheap attempted counts, the engine caps counts by free places, then individuals(places, date) generates exactly those admitted records. User records supply existing location columns, start equal to the current simulation date and a later end Date. IDs, attributes, optional duration fields and other output columns are user-defined; the simulator no longer generates IDs/admission/discharge/los columns or predeclares a person-output schema. Internal vectors track location indices and end dates solely for availability. Output is the generated admitted records only, or an empty tibble; blocked arrivals are not generated or queued. Optional location parameters may be dropped by the individual generator as long as location keys are preserved in row order. Updated source, concise help and vignette; removed obsolete los global and row_number package import. Population tests passed, including generation counts matching admitted records, exact reuse at end, custom date/location rules, arbitrary typed attributes, no generation for zero availability, and invalid periods/counts. Vignette rendered and occupancy/record ownership checks passed. R CMD check completed with zero errors, zero warnings and zero notes. graphify update . completed with existing external-node source metadata warnings.

## Outcome

- Signal: corrected
- Correction: The user rejected generating complete candidate people before checking space. For this simulation, draw attempted counts, cap by available places, and generate complete user-defined individual records only for the admitted count. Keep minimal required location/start/end information for tracking, with all individual fields supplied by the user function. Do not implement the pre-generated request-table plus accepted/rejected-list proposal.

## Source Nodes

- make_population()
- make_landscape()