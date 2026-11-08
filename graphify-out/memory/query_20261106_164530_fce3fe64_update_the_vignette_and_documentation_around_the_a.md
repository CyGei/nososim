---
type: "query"
date: "2026-11-06T16:45:30.175899+00:00"
question: "Update the vignette and documentation around the agreed clean workflow, clearly separating user inputs from generated population fields."
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_population()", "make_landscape()"]
---

# Q: Update the vignette and documentation around the agreed clean workflow, clearly separating user inputs from generated population fields.

## Answer

Updated documentation only; simulation logic unchanged. Vignette retains the supplied nested hospital example, now leads with required locations/n and a minimal user admissions function attempting one arrival per location/day. The user individuals function only adds sampled age and location-dependent positive integer los. Added a concise ownership table separating user labels/n, user arrival counts and attributes/los from simulator-generated location reference, IDs, admission and discharge. Moved optional parameters to a separate section using a user-chosen rate column and custom random_admissions; explicitly states there is no built-in admission_rate column or arrival distribution. Package help now distinguishes required location input n, optional user metadata, reserved generated fields, callback-provided los and simulator-calculated dates. Regenerated help. Rendered the vignette and verified both minimal and optional-rate workflows, unmodified input schema without generated fields or rates, unique IDs, conditional LOS and per-location occupancy limits. git diff --check passes; graphify update . completed with existing external-node source metadata warnings.

## Outcome

- Signal: useful

## Source Nodes

- make_population()
- make_landscape()