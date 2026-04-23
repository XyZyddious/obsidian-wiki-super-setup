---
type: meta
title: "Misc Index"
created: 2026-04-23
updated: 2026-04-23
tags: [meta, index]
status: evergreen
summary: >-
  Holding pen for un-routed pages. Pages here earn their way into a project
  folder once their cross-linker affinity score reaches 3+.
provenance:
  extracted: 1.0
  inferred: 0.0
  ambiguous: 0.0
confidence: high
related:
  - "[[../index]]"
sources: []
---

# Misc

Holding pen. When a page doesn't fit any existing category or project on first ingest, it lands here. As the wiki grows, cross-linker tracks how many other pages reference each misc page — once a project's "affinity score" for a misc page hits 3+, lint flags it for promotion.

## What goes here

- Sources you're not sure how to categorize yet.
- Concepts that might end up belonging to a future project.
- Pages that deliberately don't have a home (e.g. random observations).

## Affinity & promotion

`cross-linker` adds an `affinity:` block to misc pages:

```yaml
affinity:
  project/wiki-rebuild: 4
  domain/research: 2
  domain/personal: 1
```

When any score ≥ 3 AND the project exists, `wiki-lint` flags the page with: "Promote to projects/<name>/?"

## Pages

<!-- Pages live here until promoted or pruned. -->

_None yet._

## Hygiene

- Pages stuck in misc for >90 days with affinity < 3 should be pruned, not held forever.
- Pages with `status: superseded` shouldn't live here — move them to the relevant project's `_archive/` or actually delete.
