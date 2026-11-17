---
type: "query"
date: "2026-11-13T12:34:50.009207+00:00"
question: "Can you do a complete analysis of the current codebase."
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_outbreak()", "make_population()", "get_contacts()"]
---

# Q: Can you do a complete analysis of the current codebase.

## Answer

Expanded graph vocabulary: landscape, population, outbreak, contacts, timeline, simulacr, admission, discharge, infection, hazard. Source verification supersedes stale graph descriptions of normalized contacts. Current make_outbreak already calls simulacr::simulate_outbreak_step daily (R/make_outbreak.R:113); upstream main and DESCRIPTION-pinned step source have the same blob. make_population precomputes all stays/admissions, so dynamic infection-dependent occupancy is the missing architectural feature. Recommend preserving existing constructors and contact callbacks, adding an optional population_step(state, date) to make_outbreak, and sharing one internal population-step kernel with make_population. Keep persistent IDs/infection history separate from current presence and location capacity; retain realised presence history. Apply previous-step infections before disease-dependent departure decisions, then departures/transfers/attendance, available capacity and admitted individuals, contacts and modifiers, upstream step, and recording t+1 infections. Generate individual attributes only for accepted entrants. Use a one-time LOS extension or elapsed-stay conditional departure hazard; do not repeatedly redraw full stays. Initial residents need a meaningful residual LOS or burn-in. C is binary support times multiplicative weights without normalization, source rows and recipient columns. Source controls modify tau, recipient protection modifies columns; movement/reallocation changes assignments and rebuilds support/weights. Current vignette staff contacts span the whole hospital, so changing ward does not remove cross-ward binary edges. Transmission forest should accompany realised presence, events and parameters. Consolidate legacy id/date/R_i timeline API with canonical id/start/end presence; improve typed empty output, identity/date validation, PMF validation, compact printing and documentation. Cumulative outgoing FOI is not realised offspring or exact R; spectral radius of diag(tau) C is only a static linearised diagnostic under stated assumptions. Upstream w(0) yields events one day later, and I persists after infection; separate clinical disease status. Tests pass 87 expectations and current vignette executes, producing 390 presence rows, 143 IDs and 16 cases on installed dependencies. Installed simulacr commit differs from declared pin. dplyr minimum should cover relationship join argument (1.1.1). No source code modified; recommendations are proposed, not implemented.

## Outcome

- Signal: useful

## Source Nodes

- make_outbreak()
- make_population()
- get_contacts()