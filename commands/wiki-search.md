---
description: Scale-up search for vaults beyond ~200 pages. Wraps optional BM25 (qmd) + vector search with reciprocal-rank fusion. Falls back to grep if no search backend installed. For most queries, wiki-query is faster — use this when frontmatter grep gets slow.
---

Read the `wiki-search` skill (`skills/wiki-search/SKILL.md`). Then run the search.

## Usage

- `/wiki-search <query>` — search the wiki for a phrase or concept
- `/wiki-search <query> tag:<tag>` — restrict to pages with this tag
- `/wiki-search <query> type:<type>` — restrict to a page type
- `/wiki-search <query> --top 20` — change result count (default 10)

## Behavior

1. Detect available backends: `qmd` (BM25), vector backend (if `wiki/meta/search-config.md` exists), or fallback to `grep`.
2. Construct the query (extract terms, parse filters, apply default `visibility/public` filter).
3. Run search against the best available backend.
4. If both qmd and vector backend available AND query is conceptual (>4 words OR contains "similar to"), run both and fuse via reciprocal-rank fusion.
5. Format results: page link + summary + match snippet + confidence/provenance.
6. Offer file-back: "File this search result + synthesis as a `wiki/questions/` page?"

## When NOT to use

- Vaults under ~200 pages — `wiki-query` Tier 1 (frontmatter grep) is faster.
- Looking up a specific page by name — use `wiki-query` with `title:` filter.
- Asking a question that needs synthesis — `wiki-query` standard or deep mode is better.
