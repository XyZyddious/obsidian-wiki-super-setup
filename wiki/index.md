---
type: meta
title: "Wiki Index"
created: 2026-04-23
updated: 2026-04-23
tags: [meta, index]
status: evergreen
summary: >-
  Master catalog of the wiki. Read first when you don't know where to look.
provenance:
  extracted: 1.0
  inferred: 0.0
  ambiguous: 0.0
confidence: high
related:
  - "[[overview]]"
  - "[[hot]]"
  - "[[log]]"
  - "[[meta/taxonomy]]"
  - "[[meta/insights]]"
  - "[[meta/dashboard]]"
sources: []
---

# Wiki Index

Total pages: 0 | Sources ingested: 0

Navigation: [[overview]] | [[hot]] | [[log]] | [[meta/insights]] | [[meta/taxonomy]] | [[meta/dashboard]]

> **Reading discipline:** read this index first, then drill into a sub-index, then a page.
> For "what changed lately?" check [[hot]] (recent context) or [[log]] (chronological).

---

## Universal categories

These exist in every wiki regardless of domain:

- [[concepts/_index]] — frameworks, models, ideas
- [[entities/_index]] — people, organizations, products, repos, places
- [[sources/_index]] — per-source summary pages (one per item in `.raw/`)
- [[comparisons/_index]] — side-by-side analyses
- [[questions/_index]] — filed answers to questions you've asked
- [[references/_index]] — quick-reference cheat sheets
- [[journal/_index]] — time-stamped session/meeting/decision notes
- [[projects/_index]] — project-scoped knowledge
- [[misc/_index]] — un-routed pages awaiting promotion

## Operational pages

- [[hot]] — session bridge (~500 words of recent context)
- [[log]] — append-only chronological journal
- [[overview]] — executive summary of the vault
- [[meta/taxonomy]] — canonical tag vocabulary
- [[meta/insights]] — auto-generated graph health (hubs, bridges, gaps)
- [[meta/dashboard]] — Dataview/Bases dashboard

## Drafts staging

- `wiki/_raw/` — in-vault drafts (you type here, Claude promotes)
- `.raw/` — source documents (immutable, hidden from Obsidian)

---

## Hubs (top 10 pages by incoming links)

<!-- Auto-populated by /wiki-status insights. Do not edit by hand. -->

_None yet — vault is fresh._

## Recent (last 7 days)

<!-- Auto-populated by /wiki-ingest. Do not edit by hand. -->

_None yet — drop a source into `.raw/` to start._

---

## How to use

- **Add a source**: drop into `.raw/`, then say `ingest [filename]` (or `ingest all of these`).
- **Type a draft**: write into `wiki/_raw/`, then say `ingest raw drafts`.
- **Ask a question**: just ask. Good answers get filed back to `wiki/questions/`.
- **Maintain**: `lint the wiki` every 10-15 ingests; `wiki status` weekly; `cross-link` after big ingests.
- **Visualize**: `export the wiki graph` — opens in `_attachments/wiki-export/graph.html`.

See [[overview]] for what this wiki is and the architecture behind it.
