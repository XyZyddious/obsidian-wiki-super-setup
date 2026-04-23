---
type: meta
title: "Hot Cache"
created: 2026-04-23
updated: 2026-04-23
tags: [meta, hot-cache]
status: evergreen
summary: >-
  Session bridge — ~500 words of recent context, automatically refreshed at SessionStop.
  Read this first when resuming work.
provenance:
  extracted: 1.0
  inferred: 0.0
  ambiguous: 0.0
confidence: high
related:
  - "[[index]]"
  - "[[log]]"
  - "[[overview]]"
sources: []
---

# Hot Cache

This is your session bridge. ~500 words of the most recent context, refreshed by the `SessionStop` hook (or via the `update hot cache` command). Read first when resuming.

---

## Right now

**Vault status:** Fresh install. Nothing ingested yet.

**Active threads:** None.

**Open questions in the vault:** None.

**Next likely actions:**
- Drop a first source into `.raw/` and run `ingest <filename>`.
- Or test the workflow: `cp examples/article.md .raw/` then `ingest .raw/article.md`.
- Customize `wiki/meta/taxonomy.md` with your own domain tags (or skip — Claude will ask about new tags as content arrives).
- Add domain-specific subfolders under `wiki/projects/<your-project>/` as needed.

---

## How to read this file

The `update hot cache` command and `SessionStop` hook overwrite the section below. Treat the section above as relatively stable until you've ingested enough content for the auto-refresh section to take over.

<!-- BEGIN AUTO-REFRESH -->

_Nothing logged yet — drop a source into `.raw/` to start._

<!-- END AUTO-REFRESH -->
