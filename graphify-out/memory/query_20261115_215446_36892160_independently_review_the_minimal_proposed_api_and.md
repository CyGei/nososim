---
type: "query"
date: "2026-11-15T21:54:46.158167+00:00"
question: "Independently review the minimal proposed API and use infection dates from simulate_outbreak_step instead of newly_infected."
contributor: "graphify"
outcome: "corrected"
correction: "The preceding t+1 statements remain true for the current local dependency pin, but no longer describe upstream main after commit 349c311e16acfb00728dde8fa98309fc7a118967. Target current upstream t semantics and use end-of-day daily update; do not retain a newly_infected flag or silently mix timing conventions."
source_nodes: ["make_population()", "make_outbreak()", "get_contacts()"]
---

# Q: Independently review the minimal proposed API and use infection dates from simulate_outbreak_step instead of newly_infected.

## Answer

Independent review by a new fork_turns=none agent, with no conversation history, found the earlier update-before-departure/admissions/imports order cyclic. Critical verification on 2026-11-15: upstream simulacr changed on 2026-11-14, commit 349c311e16acfb00728dde8fa98309fc7a118967 (file blob 34edefb21cd22b87696150537ddf6e86e5148c9b), now dates new infections/tree events t, not t+1. Upstream roxygen still says t+1. Local pinned f260d8... and installed version remain t+1. Final target design uses verified current upstream: each day admit/initialise into yesterday's vacancies -> introduce cases dated t -> build contacts/save contact-time snapshot -> simulate_outbreak_step -> join infection state -> run update once on all present at t -> depart at end when as.integer(t-start)+1 >= stay. Updates alter departures immediately and next-day contact attributes. date_infection == t, with NA treated false, allows a single stay column and one-time extension without baseline_stay, newly_infected, event, on_infection, or departures callbacks. Initial draws occur only in individuals; mutable updates persist. make_population stores landscape, admissions(available,landscape,t), individuals(data,t), update(data,t); no simulation dates. make_outbreak runs one or named independent population models; imported(data,t) returns labels selected from susceptible occupants, infection date supplied by engine. get_contacts handles already-present snapshots. tau is an individual attribute and update can alter it; a separate time-varying tau callback is redundant for this target design. Preserve labels/infection history across shifts and input Date values, converting only at upstream boundary. Return contact-time population history and upstream-shaped infection forest from/to/date; do not misattribute end-of-day changed attributes to earlier contacts. Pin exact verified repo commit and test dates before implementation. A small executed R check against current upstream verified same-day events, no within-step cascade, final-day extension before departure, and no repeated extension tomorrow. No package source changed. Expanded graph terms: make_outbreak simulate_outbreak_step population imports.

## Outcome

- Signal: corrected
- Correction: The preceding t+1 statements remain true for the current local dependency pin, but no longer describe upstream main after commit 349c311e16acfb00728dde8fa98309fc7a118967. Target current upstream t semantics and use end-of-day daily update; do not retain a newly_infected flag or silently mix timing conventions.

## Source Nodes

- make_population()
- make_outbreak()
- get_contacts()