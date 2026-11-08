---
type: "query"
date: "2026-11-08T14:54:07.749178+00:00"
question: "Restore the nested landscape stay plot for autoplot using the current make_population output, keeping code concise."
contributor: "graphify"
outcome: "useful"
source_nodes: ["autoplot.nososim_population()", "population_positions()", "make_population()"]
---

# Q: Restore the nested landscape stay plot for autoplot using the current make_population output, keeping code concise.

## Answer

Implemented autoplot.nososim_population in R/autoplot.R, reusing the nested layout from the saved pre-cleanup implementation. It draws full start/end segments directly, with one display row per available place, grey background rows for unused places, input hierarchy order and legendry::guide_axis_nested labels. A single private population_positions helper matches hierarchy keys and greedily assigns nonoverlapping stays to display rows, reusing rows on exclusive end dates; user record columns remain unchanged. make_population now returns a nososim_population tibble subclass with locations and dates metadata for S3 dispatch and empty-place plotting; no new person columns are added. Restored the legendry >=0.3.0 import and registered/documented the population method; legacy daily timeline and outbreak methods retain behavior. Updated the existing vignette to call autoplot(rate_population, aes(colour=id)) with hidden legend. Added meaningful tests for exact segment endpoints, full available-place rows, nested labels, no overlap/reuse, genuine and filtered empty populations, zero-place landscapes, unequal depths/underscores and invalid edited overlaps. Focused plot/population tests passed; vignette rendered, and the actual nested PNG was visually inspected at /tmp/nososim-nested-stays.png. R CMD check completed with zero errors, zero warnings and zero notes. git diff --check passed and graphify update . completed with existing external-node source metadata warnings.

## Outcome

- Signal: useful

## Source Nodes

- autoplot.nososim_population()
- population_positions()
- make_population()