---
type: meta
title: "Vault Dashboard"
created: 2026-04-23
updated: 2026-04-23
tags: [meta, dashboard]
status: evergreen
summary: >-
  Live dashboard of the vault — recent pages, status counts, hub pages, lint
  flags. Requires the Dataview plugin for live queries.
provenance:
  extracted: 1.0
  inferred: 0.0
  ambiguous: 0.0
confidence: high
related:
  - "[[index]]"
  - "[[overview]]"
  - "[[insights]]"
sources: []
---

# Vault Dashboard

Live dashboard. Requires the **Dataview** plugin (Settings -> Community plugins -> Dataview).

If Dataview isn't installed, the queries below will render as code blocks — the structure still works as a checklist of "what to look at."

---

## Recent pages (last 14 days)

```dataview
TABLE updated, status, summary
FROM "wiki"
WHERE updated >= date(today) - dur(14 days)
SORT updated DESC
LIMIT 20
```

## Status breakdown

```dataview
TABLE length(rows) as count
FROM "wiki"
GROUP BY status
SORT count DESC
```

## Pages by type

```dataview
TABLE length(rows) as count
FROM "wiki"
GROUP BY type
SORT count DESC
```

## Pages missing required fields

```dataview
LIST
FROM "wiki"
WHERE !summary OR !provenance OR !confidence
```

## Pages with low confidence

```dataview
LIST
FROM "wiki"
WHERE confidence = "low"
SORT updated DESC
```

## Pages flagged for review (high ambiguous %)

```dataview
LIST "Ambiguous: " + provenance.ambiguous
FROM "wiki"
WHERE provenance.ambiguous > 0.15
SORT provenance.ambiguous DESC
```

## Pages with `visibility/internal` or `visibility/pii`

```dataview
TABLE file.tags as tags, updated
FROM "wiki"
WHERE contains(file.tags, "#visibility/internal") OR contains(file.tags, "#visibility/pii")
SORT updated DESC
```

## Open questions

```dataview
LIST
FROM "wiki/questions"
WHERE answer_quality != "definitive"
SORT updated DESC
```

## Decisions awaiting resolution

```dataview
LIST
FROM "wiki"
WHERE type = "decision" AND decision_status = "proposed"
SORT priority ASC
```

---

## How to read this dashboard

- **Recent pages**: what you've been working on. If empty, the wiki is idle.
- **Status breakdown**: too many `seed` = too many starts, not enough development. Too many `superseded` without restoration = clutter.
- **Pages missing required fields**: lint will flag these. Fix or run `wiki-lint --fix`.
- **Low confidence + high ambiguous**: re-ingest the supporting source or flag for review.
- **Visibility flagged**: spot-check that nothing got mistagged.
- **Open questions**: candidates for `/autoresearch` or focused reading.
- **Decisions in proposed state**: things you've started thinking through but haven't committed to.
