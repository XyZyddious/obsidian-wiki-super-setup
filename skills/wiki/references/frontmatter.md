# Universal Frontmatter Spec

Every wiki page carries this frontmatter. Type-specific fields go below the universal ones. Pages missing required fields get flagged by `wiki-lint`.

## Required (every page)

```yaml
type: source|entity|concept|comparison|question|project|decision|meeting|journal|reference|meta
title: "Human-Readable Title"
created: 2026-04-23                      # ISO date
updated: 2026-04-23                      # ISO date — update on every edit
tags: [domain-tag, type-tag]             # max 5; canonical from wiki/meta/taxonomy.md
status: seed|developing|mature|evergreen|superseded

# LOAD-BEARING for cheap retrieval
summary: >-
  One or two sentences (≤200 chars) describing what this page is about,
  written so a reader who hasn't opened it can preview it.

# Provenance discipline
provenance:
  extracted: 0.72                        # rough fraction (no marker)
  inferred: 0.25                         # rough fraction (^[inferred])
  ambiguous: 0.03                        # rough fraction (^[ambiguous])
                                         # should sum to ~1.0
confidence: high|medium|low              # page-level confidence
```

## Strongly recommended

```yaml
related:                                 # other wiki pages this one connects to
  - "[[Other Page]]"
sources:                                 # source pages backing this content
  - "[[wiki/sources/source-slug]]"
```

## Supersession (rohitg00 pattern — only on supersession events)

```yaml
superseded_by: "[[Newer Page]]"          # set on the OLD page; status flips to "superseded"
supersedes: "[[Older Page]]"             # set on the NEW page
```

## Visibility (system tags — exempt from 5-tag limit)

Add to `tags:` array as strings:

```yaml
tags: [concept, machine-learning, "visibility/internal"]
```

| Tag | Meaning | Default |
|---|---|---|
| `visibility/public` | Safe to share / export | yes (implicit) |
| `visibility/internal` | Work-confidential | no |
| `visibility/pii` | Contains personal info | no |

`wiki-lint` scans for PII patterns. `wiki-export` defaults to public-only.

---

## Type-specific extensions

### `source`

```yaml
source_type: article|video|podcast|paper|book|transcript|data|web|image|meeting|email|conversation
author: ""
date_published: 2026-04-23
url: ""
key_claims: ["First key claim", "Second key claim"]
raw_path: ".raw/path-to-original"
```

### `entity`

```yaml
entity_type: person|organization|product|repository|place|event
role: ""
first_mentioned: "[[Source Title]]"
aliases: ["abbreviation", "nickname"]
url: ""
```

### `concept`

```yaml
complexity: basic|intermediate|advanced
domain: ""
aliases: ["abbreviation"]
```

### `comparison`

```yaml
subjects: ["[[Thing A]]", "[[Thing B]]"]
dimensions: ["performance", "cost", "complexity"]
verdict: "One-line conclusion."
```

### `question`

```yaml
question: "Original query as asked, verbatim."
answer_quality: draft|solid|definitive
asked_by: ""
asked_at: 2026-04-23
```

### `project`

```yaml
project_status: active|paused|shipped|abandoned
owner: ""
start_date: 2026-04-23
target_date: 2026-12-31
key_links: ["url1", "url2"]
```

### `decision`

```yaml
decision_status: proposed|accepted|superseded|abandoned
priority: 3                              # 1 (high) - 5 (low)
owner: ""
due_date: 2026-04-30
context: ""
```

### `meeting`

```yaml
date: 2026-04-23
attendees: ["[[Person A]]", "[[Person B]]"]
project: "[[Project]]"
recordings_url: ""
decisions_made: ["[[Decision]]"]
action_items: []
```

---

## Inline provenance markers (in body, not frontmatter)

Place AFTER the claim, BEFORE the period:

```markdown
The Forgetting Curve was first described by Ebbinghaus^[inferred] in 1885^[ambiguous].
Most production wikis exceed 200 pages within six months^[inferred] of active use.
```

- No marker = EXTRACTED (default — directly from source).
- `^[inferred]` = your synthesis or extrapolation.
- `^[ambiguous]` = sources disagree, or you're uncertain.

`wiki-lint` recomputes the rough fractions periodically and flags drift > 0.20 from the frontmatter values.

---

## Affinity (set by cross-linker on misc/ pages)

```yaml
affinity:
  project/wiki-rebuild: 4
  domain/research: 2
  domain/personal: 1
```

Pages in `wiki/misc/` only. Promoted to `projects/<name>/` once any score ≥ 3 AND the project exists.

---

## Validation checklist

Before saving any page:

- [ ] `type` is one of the allowed values
- [ ] `title` matches the filename (Title Case)
- [ ] `created` and `updated` are ISO dates
- [ ] `tags` ≤ 5 (excluding `visibility/*`)
- [ ] All tags exist in `wiki/meta/taxonomy.md`
- [ ] `status` is one of the five values
- [ ] `summary` exists and is ≤ 200 characters
- [ ] `provenance` block sums to ~1.0
- [ ] `confidence` is one of high|medium|low
- [ ] Type-specific fields are populated where applicable
- [ ] Inline `^[inferred]` / `^[ambiguous]` markers are consistent with the `provenance:` block
