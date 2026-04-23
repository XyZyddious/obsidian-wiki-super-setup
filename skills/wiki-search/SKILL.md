---
name: wiki-search
description: Scale-up search for vaults beyond ~200 pages, where frontmatter grep gets slow. Wraps optional BM25 (qmd) for keyword matching with stemming and synonym expansion, optional vector search for semantic similarity, and reciprocal-rank-fusion to combine them. Falls back to grep automatically when no search backend is installed. Use when user says "search the wiki", "find pages about X", "semantic search", "BM25 search", "wiki-search", "I can't find what I wrote about X".
---

# wiki-search

Heavier search for when the retrieval-primitives ladder in `wiki-query` Tier 1 (frontmatter grep) and Tier 3 (sectioned grep) start getting slow at scale.

`wiki-query` is still the right tool for most queries. `wiki-search` is what you reach for when:

- The vault has > 200 pages and grep is taking >2 seconds
- You're searching for a concept that doesn't appear by exact name (semantic match needed)
- You want ranked results across the full vault, not just an answer

## Backends

This skill is **optional infrastructure**. It works without any external dependency by falling back to grep, but adding a real search backend makes it dramatically faster.

### Tier 1: BM25 via qmd (recommended)

[qmd](https://github.com/quranscript/qmd) is a local CLI that indexes Markdown files for fast keyword search with stemming and synonym expansion.

```bash
# Install (one-time)
pip install qmd

# Index the vault (run once after setup, then after every wiki-rebuild)
qmd index /path/to/vault/wiki

# Search
qmd search "hybrid retrieval" --top 10
```

The skill detects qmd via `which qmd` and uses it if available.

### Tier 2: Vector search (optional, advanced)

For semantic matching ("pages similar to X"), use a local vector search backend like `lancedb` or `chromadb`. Document your setup in `wiki/meta/search-config.md` and the skill will use it.

### Tier 3: Fallback (always available)

If neither qmd nor a vector backend is installed, the skill uses `grep -r` over `wiki/` body content with a configurable result limit. Slower but always works.

## Workflow

### Step 1: Detect available backends

```
qmd?     -> $(which qmd >/dev/null && echo yes)
vector?  -> $(test -f wiki/meta/search-config.md && echo yes)
fallback -> grep
```

### Step 2: Construct query

Take the user's natural-language query and:
- Extract key terms (exclude stopwords)
- Identify any tag filters (`tag:concept`, `type:source`, `project:foo`)
- Identify any visibility filter (default: `visibility/public` only)
- Identify any time-window filter (`updated:>2026-04-01`)

### Step 3: Run search

#### If qmd available
```bash
qmd search "hybrid retrieval" \
  --filter "type:concept OR type:question" \
  --filter "visibility:public" \
  --top 10 \
  --format json
```

#### If vector backend available AND query is conceptual (>4 words OR contains "similar to" / "like X")
- Run both BM25 and vector queries
- Apply reciprocal-rank fusion to combine: `score = sum(1 / (60 + rank_i))` over each result list
- Take top 10

#### Fallback: grep
```bash
grep -rln "<term>" wiki/ \
  --include="*.md" \
  --exclude-dir=meta \
  | head -10
```

### Step 4: Format results

For each result, show:
- Page link `[[wiki/path/title]]`
- Type and status
- Summary (from frontmatter — load-bearing)
- Match snippet (3-line context around the hit)
- Confidence and provenance fractions

```
Search: "hybrid retrieval" — 8 results

1. [[wiki/concepts/Reciprocal Rank Fusion]] (concept, mature, conf:high)
   Combine BM25 and vector results via 1/(60+rank) sum.
   Match: "Hybrid retrieval combines keyword matching (BM25) with..."
   Provenance: 0.85 extracted / 0.13 inferred / 0.02 ambiguous

2. [[wiki/questions/Should we go hybrid?]] (question, definitive, conf:medium)
   Yes — hybrid wins precision-at-1 by ~8% on short queries.
   Match: "...moving from pure vector retrieval to BM25 + vector hybrid..."
   ...
```

### Step 5: File-back option

If the search produced a useful answer the user wants to keep, offer:
> "File this search result + synthesis as a `wiki/questions/` page?"

If yes, route to `save` skill with the search query as the question and the synthesis as the answer.

## When NOT to use this skill

- Vaults under ~200 pages — `wiki-query` Tier 1 (frontmatter grep) is faster
- Looking up a specific page by name — `wiki-query` Tier 1 with `title:` filter is exact
- Asking a question that needs synthesis — `wiki-query` standard or deep mode is better

## Configuration

Optional `wiki/meta/search-config.md` with frontmatter:

```yaml
---
type: meta
title: "Search Config"
qmd_path: "/usr/local/bin/qmd"
vector_backend: "lancedb"
vector_db_path: "~/.local/share/wiki-vectors"
default_top_k: 10
default_filters: ["visibility/public"]
fusion_constant: 60
---
```

If absent, defaults are: try qmd if installed, no vector search, top 10, public-only.

## Re-indexing

Indexes go stale as the wiki evolves. Run `qmd index wiki/` after:
- Any `wiki-rebuild` operation
- Any `wiki-ingest` batch of >5 sources
- Weekly as standard hygiene

The skill will warn if its index is older than 14 days.

## Cross-skill integration

- Routed from `wiki-query` when frontmatter grep returns >50 candidates (a sign the query is ambiguous)
- Routed from `wiki-status insights` when surfacing surprising connections (semantic search finds non-obvious neighbors)
- Indexes get rebuilt by a hook after `wiki-rebuild` or large `wiki-ingest` batches
