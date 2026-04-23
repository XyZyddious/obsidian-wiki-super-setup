---
type: meta
title: "Vault Overview"
created: 2026-04-23
updated: 2026-04-23
tags: [meta, overview]
status: evergreen
summary: >-
  Executive summary of the vault — what it is, who it's for, the architecture,
  and the conventions every page follows.
provenance:
  extracted: 0.85
  inferred: 0.15
  ambiguous: 0.0
confidence: high
related:
  - "[[index]]"
  - "[[hot]]"
  - "[[log]]"
  - "[[meta/taxonomy]]"
sources: []
---

# Vault Overview

**Schema version:** 1.0

This is an LLM-maintained, persistent, compounding knowledge base. You drop sources into `.raw/`, ask Claude any question, and the wiki grows richer with every session.

## What makes this different from a chat history or a RAG system

- **Compounds.** Every ingest tightens cross-references. Every answer can be filed back as a new page.
- **Cited.** Answers reference specific wiki pages, not training data or generic similarity hits.
- **Provenance-aware.** Every page declares what fraction is extracted vs. inferred vs. ambiguous.
- **Self-maintaining.** Lint catches drift. Cross-linker auto-tightens. Status surfaces gaps.
- **Local-first.** All markdown, all yours, no vendor lock-in. Open in any editor.

## The four pillars (one per source implementation)

| Pillar | From | What it gives you |
|---|---|---|
| 3-layer model + index/log/hot | Karpathy + agrici | Sources / wiki / schema separation. Read order: index -> sub-index -> page. |
| Provenance + confidence + supersession | rohitg00 | Knowing what's reliable vs. speculative; replacing decisions cleanly. |
| Templates + manifest + .raw discipline | agrici | Concrete structure, hash-based delta tracking, custom callouts. |
| summary + retrieval ladder + cross-linker + insights | ar9av | Cheap retrieval at scale; auto-link; graph-aware insights. |

## Reading order for newcomers

1. [[index]] — master catalog
2. [[overview]] — this page
3. `CLAUDE.md` (vault root) — the contract
4. `skills/wiki/references/frontmatter.md` — what every page must carry
5. [[meta/taxonomy]] — tag vocabulary

## Maintenance cadence

- **After every ingest**: cross-linker runs (automatic).
- **Every 10-15 ingests**: `lint the wiki`.
- **Weekly**: `wiki status` and `wiki insights`.
- **Monthly**: `wiki export`.
- **When schema evolves**: edit `CLAUDE.md` deliberately and bump the version note here.

## Glossary

- **EXTRACTED claim** — directly from a source. No inline marker.
- **INFERRED claim** — synthesis or extrapolation. Marked `^[inferred]`.
- **AMBIGUOUS claim** — sources disagree or Claude is uncertain. Marked `^[ambiguous]`.
- **Hub page** — a page in the top 10 by incoming wikilinks.
- **Bridge page** — the only path between two tag clusters.
- **Orphan page** — no incoming wikilinks; lint flags these.
- **Hot cache** — `wiki/hot.md`, the ~500-word session bridge.
- **Affinity** — cross-linker score for `misc/` pages, used to promote them to projects.
