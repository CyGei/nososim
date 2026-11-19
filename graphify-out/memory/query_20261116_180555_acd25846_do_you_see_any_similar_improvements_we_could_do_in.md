---
type: "query"
date: "2026-11-16T18:05:55.950299+00:00"
question: "Do you see any similar improvements we could do in admit_individuals()?"
contributor: "graphify"
outcome: "useful"
source_nodes: ["admit_individuals()", "check_attributes()"]
---

# Q: Do you see any similar improvements we could do in admit_individuals()?

## Answer

There are fewer strong simplifications in admit_individuals() than in make_outbreak(). Graph query scoped to admit_individuals; relevant graph vocabulary [admit, individuals]. Source and tests reviewed.
1. R/population.R:103 rename data to entrants to distinguish attributed people from the admitted location rows.
2. R/population.R:106-109 replace the one-use keys variable and nested list conversion comparison with purrr::every(level_columns(admitted), function(column) identical(entrants[[column]], admitted[[column]])) inside stopifnot. This states the per-column preservation requirement explicitly. Installed R checks agreed with the old comparison for unchanged, reordered, type-changed, empty and extra-column inputs. Keep identical to preserve strict value, order and type comparisons.
3. R/population.R:113-117 optionally use entrants |> mutate(labels = c(.env$known_labels, simulacr::draw_labels(dplyr::n())) |> make.unique() |> utils::tail(dplyr::n())) inside the existing missing-label if block. This matches the chosen tidyverse style but is longer than the direct assignment. Keep make.unique and the conditional for collision safety and supplied returning identities.
Keep tabulate(), location_indices, the early return, and the two pre/post-callback tables. An uncount rewrite must add a landscape row identifier before expansion, hide it from attributes, and restore it afterwards; this is more boundary handling merely to remove one vector. current[0, ] is also already concise and does not need replacing just to avoid base R. No source edits made.

## Outcome

- Signal: useful

## Source Nodes

- admit_individuals()
- check_attributes()