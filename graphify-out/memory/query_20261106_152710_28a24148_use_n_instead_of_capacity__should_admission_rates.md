---
type: "query"
date: "2026-11-06T15:27:10.443319+00:00"
question: "Use n instead of capacity. Should admission rates belong to make_landscape or elsewhere, and what is the most elegant approach?"
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_landscape()"]
---

# Q: Use n instead of capacity. Should admission rates belong to make_landscape or elsewhere, and what is the most elegant approach?

## Answer

User prefers n as the terminal-location count. The user had already renamed the function output and vignette aggregation; remaining tests, generated help and prose were synchronized, and the obsolete capacity global was removed. Focused landscape tests and vignette rendering pass; graphify update . completed. Architecture recommendation for discussion only: keep make_landscape() constructing the physical location table. Attach location-specific admission_rate parameters to the resulting table with ordinary dplyr mutate(), and let the future make_population() sample and allocate admissions from them. State rate units and scope explicitly: a column on terminal room rows can mean attempted entries per room per day. A ward-wide arrival stream must instead be sampled once for the ward and allocated among its free descendant rooms; copying that total to every room would multiply demand. An empty-place refill hazard is a different rate interpretation and should not be conflated with area arrival counts. No admission-rate API or population generator was implemented this turn.

## Outcome

- Signal: useful

## Source Nodes

- make_landscape()