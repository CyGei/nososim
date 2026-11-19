---
type: "query"
date: "2026-11-06T15:37:43.779023+00:00"
question: "How would you construct make_population? Be clear concise and tidy."
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_landscape()"]
---

# Q: How would you construct make_population? Be clear concise and tidy.

## Answer

Proposed a core function make_population(locations, dates, individuals), with no repository source changes. The locations table contains hierarchy columns, n and per-room admission_rate. An individuals(x, date) callback preserves newly admitted location rows and adds attributes plus positive integer los; it can generate attributes before drawing location/attribute-conditioned LOS. The first version starts empty, assumes consecutive daily dates, draws Poisson arrival counts per room and lets excess demand leave. A single sorted daily loop tabulates current occupancy from prior records whose discharge exceeds the date, caps arrivals at n minus occupancy, expands admitted counts with tidyr::uncount, calls the callback, sets admission/discharge, and appends records. Unique IDs are added to the resulting person-level tibble. No bed-ID objects, nested rule resolver or separate timeline generator is needed. Executed the complete sketch in an ephemeral R session and verified per-room limits, different ward LOS, exact discharge-day reuse, zero arrivals and zero-place rooms; source files were not modified.

## Outcome

- Signal: useful

## Source Nodes

- make_landscape()