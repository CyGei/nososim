---
type: "query"
date: "2026-11-16T00:19:12.824575+00:00"
question: "Why did make_outbreak become complicated, and how can landscape -> population -> outbreak be simplified around a final population on entry?"
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_population()", "make_outbreak()", "get_contacts()"]
---

# Q: Why did make_outbreak become complicated, and how can landscape -> population -> outbreak be simplified around a final population on entry?

## Answer

Expanded graph vocabulary: landscape, population, outbreak, admission, contacts, update. Source review confirms make_population currently stores rules (R/population.R:33), while make_outbreak creates occupancy state, admits people, runs transmission, updates stays and processes departures (R/make_outbreak.R:72-195). Infection-dependent stays are the substantive reason for coupling: extending a stay changes subsequent vacancies and admissions. Recommended architecture for the requested simple workflow: make_landscape returns locations/capacities; make_population takes dates and generates completed attendance before simulation; combine patient and staff attendance before make_outbreak; make_outbreak only selects present people, joins infection history, introduces cases, builds contacts, calls simulacr::simulate_outbreak_step and accumulates events. A daily tibble unique by labels and t is a suitable shared boundary for staff schedules and time-varying attributes and already fits count_edges; stay records are a more compact alternative, but do not support both formats in the outbreak core. Keep stable identity across absences, contact matrix alignment, and daily timing checks. Remove the population-model class and generic population update callback from this baseline design. This deliberately excludes infection-dependent attendance/capacity feedback, which cannot coexist with a truly finalized schedule. Dynamic contact rules can still use infection history. Keep dates explicit to retain empty days. Existing staff vignette unnecessarily converts a prepared schedule into arrivals and then reconstructs it. Review only; no package code changed and proposal not implemented or adopted yet. Upstream simulate_outbreak_step implementation currently dates events at t despite stale t+1 documentation.

## Outcome

- Signal: useful

## Source Nodes

- make_population()
- make_outbreak()
- get_contacts()