---
type: "query"
date: "2026-11-16T17:27:12.679897+00:00"
question: "Is outbreak.R the cleanest, simplest, most readable code with as much pipe use and as few non-tidy operations and intermediate objects as possible?"
contributor: "graphify"
outcome: "useful"
source_nodes: ["make_outbreak()", "align_contacts()", "admit_individuals()"]
---

# Q: Is outbreak.R the cleanest, simplest, most readable code with as much pipe use and as few non-tidy operations and intermediate objects as possible?

## Answer

R/outbreak.R is reasonably clean, but a handful of targeted changes would improve readability. Expanded graph vocabulary: [outbreak, admit, contacts, population]. Findings checked against source and related tests.
1. R/outbreak.R:129: simplify imported records to tibble(from = NA_character_, to = introductions, date = t), removing two rep() calls. Empty introductions were checked in installed R and preserve a zero-row Date tibble.
2. R/outbreak.R:55: purrr::every(models, inherits, "nososim_population") expresses the validation more directly than all(vapply(...)).
3. R/outbreak.R:137 and :173: use distinct descriptive names for today's public occupants and full population history instead of reusing data.
4. R/outbreak.R:157: bind_rows(infections, new = _) reverses the apparent flow of the pipeline. A named new_infections value followed by bind_rows(infections, new_infections) can read better despite the additional intermediate object.
5. R/outbreak.R:96: optionally replace the indexed infection-history lookup with entrants |> mutate(population = .env$group) |> left_join(infections |> select(labels = to, date_infection = date), by = "labels"). Checked equivalence for empty infection history and mixed returning/new labels. The join relies on the existing unique infection recipient invariant and is longer than match(), so this is a preference rather than a necessary simplification.
Keep the daily and group loops, named state objects current/infections/history/known_labels, matrix indexing, and diag(C) <- 0. Their operations express the stateful algorithm directly. Maximal pipe use and minimal variable count are not reliable readability targets; the official tidyverse pipe style guide recommends named meaningful intermediate objects and one primary object per pipeline. No R source edits were made.

## Outcome

- Signal: useful

## Source Nodes

- make_outbreak()
- align_contacts()
- admit_individuals()