---
type: "query"
date: "2026-11-24T15:39:35.772212+00:00"
question: "Trace the current nososim and Simulacres contact-to-infection path and plan vaccination, isolation, cohorting and masks using source i and recipient j."
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_landscape()", "make_population()", "get_contacts()", "sample_contacts()", "make_outbreak()"]
---

# Q: Trace the current nososim and Simulacres contact-to-infection path and plan vaccination, isolation, cohorting and masks using source i and recipient j.

## Answer

Expanded from graph vocabulary: landscape population contacts multipliers outbreak simulacr transmission sample. Verified actual R source and installed simulacr RemoteSha 865331f657c4d748652584404f114727c7333444; sibling simulacr simulation bodies match installed and have no diff from pin. make_landscape flattens capacities into level_* rows. make_population provides arrivals, attributes, update callbacks; outbreak admits, imports, snapshots, builds/alines contacts, calls simulate_outbreak_step, updates and departs. get_contacts uses symmetric binary support and directed attribute multipliers without normalization. sample_contacts already implements row Poisson totals and weighted multinomial allocation; vignette calls it. Core lambda_ij=I_i*tau_i*w(t-T_i)*C_ij, recipient probability 1-exp(-S_j*column_sum(lambda)); S and I remain Boolean. Numerical fractional S is discarded by S & !new_infected. Isolation/cohort restrictions belong in contact mean before sampling; vaccine/mask residual transmission factors belong after sampling or in explicit engine susceptibility/infectiousness arguments. Plan: retain physical C, pass a separately named C_effective with recipient/pair weights and source-adjusted tau; default weights one. Use detected active isolation, define patient/staff blocks explicitly, distinguish source-only meeting rule from symmetric encounter removal. Cohort grouping without moves can restrict existing edges, but physical moves require capacity-validated transfers updating .location and level_* together because update currently forbids moves. Returning identities restore infection history only: persistent vaccine response/onset/cohort decisions require a stable roster or person registry. End-of-day updates affect next-day contacts; optional pre-transmission prepare callback should preserve identity/location/infection fields. Imports bypass local hazard and require explicit vaccination policy. Relevant existing tests pass. No implementation source changes made; proposals only.

## Outcome

- Signal: useful

## Source Nodes

- make_landscape()
- make_population()
- get_contacts()
- sample_contacts()
- make_outbreak()