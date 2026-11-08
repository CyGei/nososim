---
type: "query"
date: "2026-11-06T15:01:01.881186+00:00"
question: "Review the current code against main and suggest a very concise simple landscape and population implementation matching the whiteboard."
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_landscape()", "make_population()", "make_timeline()", "make_outbreak()"]
---

# Q: Review the current code against main and suggest a very concise simple landscape and population implementation matching the whiteboard.

## Answer

Expanded using graph vocabulary: landscape, population, location, role, stays, capacity. Verified sources against the working tree and git show main. Main R/timeline.R builds an individuals tibble using draw(), weighted attribute lists, a short attribute loop, then daily expansion. Current R/population.R adds an arrivals allocator, location_rules() nested rule resolution and separate people/timeline/admissions outputs; R/timeline.R also retains an independent bed-turnover generator. Recommendation: flatten hierarchy once in make_landscape(), have make_population() own person generation and capacity allocation and return one person-level tibble, let make_timeline() perform the daily expansion from main, and leave infection events to make_outbreak(). Preserve needed arrivals with one chronological allocation loop and explicit remaining initial stays. This is a design suggestion only; no source implementation was changed.

## Outcome

- Signal: useful

## Source Nodes

- make_landscape()
- make_population()
- make_timeline()
- make_outbreak()