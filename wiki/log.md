---
type: meta
title: "Operation Log"
created: 2026-04-23
updated: 2026-04-23
tags: [meta, log]
status: evergreen
summary: >-
  Append-only chronological journal of every operation on the wiki — ingests,
  lints, rebuilds, schema changes. Newest entries at the top.
provenance:
  extracted: 1.0
  inferred: 0.0
  ambiguous: 0.0
confidence: high
related:
  - "[[index]]"
  - "[[hot]]"
sources: []
---

# Operation Log

Append-only. Newest at the top. One entry per operation. Format:

```
## [YYYY-MM-DD HH:MM] <op> | <subject>
- pages_touched: N
- what changed: <one line>
- why: <one line>
- operator: <who ran it>
```

---

_No operations logged yet. The first ingest, lint, or rebuild will append an entry here._
