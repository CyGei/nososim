---
type: "query"
date: "2026-11-19T14:38:41.319133+00:00"
question: "Keep nodes white, colour timelines, shape nodes, label nodes, and preserve default aes."
contributor: "graphify"
outcome: "corrected"
correction: "Keep default aes(colour=labels), white nodes, colour only timelines; shape and label are optional node aesthetics."
source_nodes: ["autoplot.nososim_outbreak()"]
---

# Q: Keep nodes white, colour timelines, shape nodes, label nodes, and preserve default aes.

## Answer

Implemented in R/autoplot.R. Default mapping remains aes(colour=labels). Shape and label are removed from timeline mappings and evaluated on infection snapshots, joined with keep=TRUE to retain labels and attributes at infection time. Nodes retain white fill and grey20 outlines. Without custom shape the original imported diamond/local circle encoding remains; custom shape uses filled symbols 21:25. Label is opt-in node text. Targeted autoplot tests pass 36 assertions without warnings. This supersedes the earlier proposal to default shape to population and colour nodes.

## Outcome

- Signal: corrected
- Correction: Keep default aes(colour=labels), white nodes, colour only timelines; shape and label are optional node aesthetics.

## Source Nodes

- autoplot.nososim_outbreak()