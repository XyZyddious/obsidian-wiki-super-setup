---
name: cross-linker
description: Scored auto-link skill. Builds a registry of all wiki pages, finds unlinked mentions on each page, scores candidate links, and inserts EXTRACTED + INFERRED-confidence ones automatically. Use after every ingest, after wiki-lint, or whenever the wiki feels "loose". Run after every ingest.
---

# cross-linker

Auto-tighten the wiki by inserting wikilinks where pages mention each other but don't link.

> **Run after every ingest. New pages are almost always poorly connected.**

## Workflow

### Step 1: Build the page registry

Walk `wiki/**/*.md`. For each page, extract:

```yaml
path: wiki/concepts/Reciprocal Rank Fusion.md
title: "Reciprocal Rank Fusion"
aliases: ["RRF", "rank fusion"]   # from frontmatter
tags: [concept, search]
type: concept
incoming: 4                       # count of pages linking TO this one
outgoing: 7                       # count of [[wikilinks]] in this page's body
project: null
visibility: public
```

Cache the registry in memory for the run.

### Step 2: For each target page, find candidate links

For each page (or just the touched-pages list if invoked after ingest), scan the body and look for unlinked text mentions of:

- Other pages' titles (exact case-insensitive match, word-boundary respected)
- Other pages' aliases
- Capitalized multi-word phrases that match registry titles

For each candidate, record `{candidate_target_path, mention_text, mention_position, mention_context}`.

**Exclusions** (never auto-link):
- Inside code blocks (```...```)
- Inside inline code (`...`)
- Inside existing wikilinks (`[[...]]`)
- Inside YAML frontmatter
- Inside HTML comments

### Step 3: Score each candidate

```
score = 0
+ 4 if exact title match (case-insensitive)
+ 3 if alias match
+ 2 if mention is a noun phrase that appears 2+ times in this page
+ 2 if shared tags between target and candidate (≥2 shared)
+ 2 if same project AND no current link
+ 2 if peripheral source page → hub target page (i.e. target has incoming ≥10, current page has incoming ≤2)
+ 1 if target page is `status: evergreen`
- 2 if target page is `status: superseded` or `status: seed`
- 1 if mention is in a section like "Related" or "See also" (already implicit)
```

### Step 4: Confidence labels

| Score | Confidence | Action |
|---|---|---|
| ≥ 6 | EXTRACTED | Auto-insert wikilink |
| 3-5 | INFERRED | Insert with `^[inferred]` marker, log for review |
| 1-2 | AMBIGUOUS | Skip, log for human review |
| ≤ 0 | — | Skip silently |

### Step 5: Insert links

Two styles:

**Inline (preferred)** — replace the first occurrence of the mention text with `[[<target-path-or-title>|<mention text>]]`. Subsequent occurrences in the same page can be left unlinked (avoid clutter).

**Bottom `## Related` section (fallback)** — when the mention is in a place where inline insertion would be awkward (table cells, code-adjacent), instead add `- [[<target>]] — mentioned <X> times` to a `## Related` section at the bottom.

### Step 6: For misc/ pages — update affinity

If the target page is in `wiki/misc/`, instead of inserting a link in the source page, update the misc page's `affinity:` block:

```yaml
affinity:
  project/wiki-rebuild: 4    # incremented from 3
  domain/research: 2
```

When any score reaches 3+ AND the corresponding project exists, log this for `wiki-lint` to flag as a promotion candidate.

### Step 7: Output the report

```
Cross-linker Report — 2026-04-23 08:00
Scope: 4 pages (post-ingest)

Auto-inserted (EXTRACTED): 12 links
  wiki/concepts/Hot Cache.md → wiki/concepts/Compounding Knowledge.md (score 8)
  wiki/sources/karpathy-llm-wiki.md → wiki/entities/Andrej Karpathy.md (score 7)
  ...

Inferred (auto-inserted with ^[inferred] marker, please review): 5
  ...

Ambiguous (skipped, listed for human review): 8
  wiki/concepts/Wiki vs RAG.md mentions "retrieval" → could mean [[Retrieval Primitives]] or [[Information Retrieval]]
  ...

Misc affinity updates: 2
  wiki/misc/Random Note.md → project/research now at affinity 4 (PROMOTION CANDIDATE)
```

### Step 8: Update wiki/log.md

```markdown
## [YYYY-MM-DD HH:MM] cross-link | scope=<post-ingest|full|tag:X|project:Y>
- pages_scanned: N
- links_inserted: M (X EXTRACTED + Y INFERRED)
- ambiguous_for_review: K
- misc_affinity_updates: P
- promotion_candidates: Q
- backlinks_emitted: R (if --emit-backlinks flag set)
```

### Step 9 (optional, with `--emit-backlinks` flag): Emit backlink frontmatter

When invoked with `--emit-backlinks`, after all link insertion is complete, compute the inverse-edge graph and emit `backlinks:` frontmatter to every touched page:

```yaml
---
# ... existing frontmatter ...
backlinks:
  - "[[Page A]]"  # Page A links here
  - "[[Page B]]"  # Page B links here
  - "[[Page C]]"
backlinks_updated: 2026-04-23T09:00:00Z
---
```

Why: this lets `wiki-query` Tier 1 (frontmatter-scoped grep) answer "what links to X?" cheaply without rebuilding the full graph. Trades a small amount of file churn (frontmatter changes when backlinks change) for a large query-speed win on large vaults.

When NOT to use:
- Vaults under ~50 pages — overhead exceeds benefit, the graph is small enough that grep finds backlinks in milliseconds anyway
- High-churn vaults where every ingest re-emits backlinks for many pages (the auto-commit hook will produce noise)

When to use:
- Vaults over ~200 pages where queries are slow
- Pre-publish polish (so forkers see backlinks immediately)
- After `wiki-rebuild` (to seed backlinks on a clean slate)

The flag is OFF by default. Pass `--emit-backlinks` explicitly to opt in.

#### Stale backlink check

When `--emit-backlinks` runs, it also detects stale backlink entries (target page no longer links to source) and removes them. Pages whose backlinks haven't been refreshed in 90 days get a flag in the report so you can re-run.

---

## Modes

### After-ingest mode (default when invoked by wiki-ingest)

Scope: only the pages in `pages_created + pages_updated` from the last ingest. Fast.

### Full mode

Scope: all of `wiki/`. Rare — only when restoring or after a big restructure. Can take time on large vaults.

### Scoped mode

`cross-link --tag <tag>` or `--project <name>` — restrict scope. Useful for fixing a specific cluster cohesion problem flagged by `wiki-lint`.

---

## What never to auto-link

- Common words ("the", "this", "page") even if they're a page title.
- Single-word lowercase mentions unless the registry entry is in lowercase too.
- Mentions inside the page's own title (self-link).
- Mentions inside YAML frontmatter (those are structured fields, not content).
- Anything that scores AMBIGUOUS — surface for human review instead.

---

## Reading list before running

1. `wiki/meta/taxonomy.md` (tag context)
2. `wiki/index.md` (catalog)
3. The page registry (compute fresh each run)
