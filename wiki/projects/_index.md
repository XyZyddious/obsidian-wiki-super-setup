---
type: meta
title: "Projects Index"
created: 2026-04-23
updated: 2026-04-23
tags: [meta, index]
status: evergreen
summary: >-
  Sub-index for projects/ — project-scoped knowledge. Each project gets a
  folder; project-specific concepts/entities/decisions live inside.
provenance:
  extracted: 1.0
  inferred: 0.0
  ambiguous: 0.0
confidence: high
related:
  - "[[../index]]"
sources: []
---

# Projects

Project-scoped knowledge. Each project gets a folder. Project-specific concepts, entities, decisions, and deliverables live INSIDE the project folder. Cross-cutting knowledge stays in the universal folders (`concepts/`, `entities/`, etc.).

## Folder pattern

```
projects/
  <project-name>/
    <project-name>.md       # project overview (NOT _project.md — see naming rule)
    concepts/
    entities/
    decisions/
    deliverables/
    journal/
    sources/                # only if sources are project-specific
```

## Naming rule

The project overview file is `<project-name>/<project-name>.md`, **not** `<project-name>/_project.md` or `<project-name>/index.md`. Reason: Obsidian's graph view uses the filename as the node label, so `_project` shows up as a node called "_project" everywhere — useless.

## When to create a project

- The work has a name and a target.
- It will accumulate ≥5 wiki pages.
- The pages would mostly only make sense in this project's context.

If you're not sure, leave content in universal folders + tag with `project/<name>`. Promote to a project folder when affinity ≥3 (cross-linker tracks this).

## Pages

<!-- Auto-populated. -->

_None yet — start a project with `start a project called <name>`._
