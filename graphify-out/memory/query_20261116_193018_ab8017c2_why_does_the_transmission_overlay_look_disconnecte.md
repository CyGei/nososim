---
type: "query"
date: "2026-11-16T19:30:18.167918+00:00"
question: "Why does the transmission overlay look disconnected? Dots should be at infection dates."
contributor: "graphify"
outcome: "corrected"
correction: "A transmission-tree overlay must connect infection nodes: source own infection date and position to recipient infection date and position. Do not locate both endpoints on the transmission date; that draws disconnected contact events."
source_nodes: ["autoplot.nososim_outbreak()"]
---

# Q: Why does the transmission overlay look disconnected? Dots should be at infection dates.

## Answer

The previous overlay put both arrow endpoints on the recipient infection date, so arrows did not start at source infection points. Corrected autoplot.nososim_outbreak to first position infection nodes using recipient label and infection date, then join source labels to those same nodes. Straight arrows connect source infection date/location to recipient infection date/location, preserving node connectivity through readmissions. Dots remain at recorded infection dates. All 35 plotting assertions pass and the updated example was rendered and inspected. Graph vocabulary: autoplot, outbreak, population, positions.

## Outcome

- Signal: corrected
- Correction: A transmission-tree overlay must connect infection nodes: source own infection date and position to recipient infection date and position. Do not locate both endpoints on the transmission date; that draws disconnected contact events.

## Source Nodes

- autoplot.nososim_outbreak()