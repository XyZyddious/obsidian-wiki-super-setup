---
type: meta
title: "Sources Index"
created: 2026-04-23
updated: 2026-04-23
tags: [meta, index]
status: evergreen
summary: >-
  Sub-index for sources/ — one page per item in .raw/. The summary, key claims,
  and entities/concepts extracted from each source.
provenance:
  extracted: 1.0
  inferred: 0.0
  ambiguous: 0.0
confidence: high
related:
  - "[[../index]]"
sources: []
---

# Sources

One page per source ingested from `.raw/`. Each page summarizes the source, lists key claims, and links the entities and concepts it introduced.

## What goes here

A `wiki/sources/` page exists for every file in `.raw/` that's been ingested. The page is the bridge between the immutable source and the LLM-derived knowledge graph — it's how every claim in the wiki traces back to its origin.

## Pages

<!-- Auto-populated by ingest. Group by source_type (article/video/paper/...). -->

_None yet — drop a source into `.raw/` and run `ingest`._

## Conventions

- Filename matches source slug (kebab-case OK here).
- `raw_path:` in frontmatter points to the original in `.raw/`.
- `key_claims:` is the load-bearing field — what would you want to remember if you only read 5 lines?
- Use `^[inferred]` for any claim that's your synthesis rather than the author's.
