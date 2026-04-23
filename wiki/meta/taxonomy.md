---
type: meta
title: "Tag Taxonomy"
created: 2026-04-23
updated: 2026-04-23
tags: [meta, taxonomy]
status: developing
summary: >-
  Single source of truth for tag vocabulary. Max 5 content tags per page.
  visibility/* tags are system tags exempt from the cap.
provenance:
  extracted: 0.5
  inferred: 0.5
  ambiguous: 0.0
confidence: medium
related:
  - "[[index]]"
  - "[[overview]]"
sources: []
---

# Tag Taxonomy

This file is the **single source of truth** for tags in the wiki. The `tag-taxonomy` skill audits pages against this list. New tags require an entry here — adding tags ad-hoc on pages is a lint warning.

## Rules

1. **Max 5 content tags per page.** `visibility/*` system tags don't count.
2. **Hierarchical tags** use `/` (e.g. `domain/research`, `type/concept`).
3. **Aliases** are normalized to canonical form by `tag-taxonomy normalize`.
4. **Tag count threshold**: a tag with fewer than 3 pages should either be removed or the pages should be re-tagged.
5. **Tag cluster cohesion**: tags with ≥5 pages whose pages don't link to each other (cohesion < 0.15) get flagged by `wiki-lint`. Use `cross-linker` on the cluster.

---

## Type tags (what the page IS)

| Tag | Use for |
|---|---|
| `type/source` | Pages that summarize a single source from `.raw/` |
| `type/entity` | People, orgs, products, repos, places |
| `type/concept` | Frameworks, ideas, models |
| `type/comparison` | Side-by-side analyses |
| `type/question` | Filed answers |
| `type/project` | Project overview pages |
| `type/decision` | Decision records |
| `type/meeting` | Meeting notes |
| `type/journal` | Time-stamped session notes |
| `type/reference` | Quick-reference cheat sheets |
| `type/meta` | Vault-operational pages (index, log, dashboards) |

## Domain tags (what the page is ABOUT)

Add your own as content arrives. Starter set:

| Tag | Use for |
|---|---|
| `domain/work` | Work-related |
| `domain/personal` | Personal life |
| `domain/research` | Active research threads |
| `domain/learning` | Things you're learning |
| `domain/health` | Health-related |
| `domain/finance` | Finance-related |
| `domain/relationships` | People-related |
| `domain/creative` | Creative work |
| `domain/admin` | Logistics, accounts, subscriptions |

_Add new domain tags here as they emerge — and only after the same word shows up on 3+ pages._

## Status tags (state of the page)

These mirror the `status:` frontmatter field but as tags for filtering:

| Tag | Use for |
|---|---|
| `status/seed` | Just created, not developed |
| `status/developing` | Active work |
| `status/mature` | Stable but might still update |
| `status/evergreen` | Reference material, rarely changes |
| `status/superseded` | Replaced by a newer page (paired with `superseded_by:`) |

## Visibility tags (SYSTEM — exempt from 5-tag cap)

| Tag | Use for | Default? |
|---|---|---|
| `visibility/public` | Safe to share or export publicly | yes (implicit) |
| `visibility/internal` | Work-confidential, do not export | no |
| `visibility/pii` | Contains personal info, never export | no |

`wiki-lint` scans page bodies for PII patterns (`password`, `api_key`, `secret`, `token`, `email:` followed by value) and flags pages that should have `visibility/pii`. `wiki-export` defaults to public-only.

## Aliases (normalized by `tag-taxonomy normalize`)

```
ml -> machine-learning
ai -> artificial-intelligence
db -> database
infra -> infrastructure
auth -> authentication
docs -> documentation
prod -> production
dev -> development
```

_Add your own aliases as you notice drift._

## Reserved prefixes

- `type/` — page type
- `domain/` — subject area
- `status/` — page state
- `visibility/` — export gating (SYSTEM)
- `project/` — project-scoping (e.g. `project/wiki-rebuild`)

Don't reuse these prefixes for ad-hoc tags.
