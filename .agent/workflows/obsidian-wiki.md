# obsidian-wiki super setup — Antigravity Workflows

Slash-command registry for Antigravity. Each command routes to a wiki skill.

See `.agent/rules/obsidian-wiki.md` for the always-on context rules and `skills/<name>/SKILL.md` for the full skill bodies.

---

## /wiki

Setup check, scaffold a new vault if needed, or route to a sub-skill based on user input. Run this first if you're not sure where to start.

→ `skills/wiki/SKILL.md`

---

## /wiki-ingest [filename] | [url] | all

Ingest a source from `.raw/` (or a URL via defuddle, or batch mode for everything in `.raw/`). Creates 8-15 wiki pages with universal frontmatter. **Pauses to ask the user about any new tag candidates** via `AskUserQuestion`. Auto-runs `cross-linker` after.

Three modes:
- `append` (default) — delta only via sha256 hash
- `full` — archive then re-ingest everything
- `raw` — process drafts in `wiki/_raw/`, delete originals

→ `skills/wiki-ingest/SKILL.md`

---

## /wiki-query [question]

Answer a question from the wiki using the 4-tier retrieval ladder (frontmatter grep → summary read → sectioned grep → full read). Three depths: `index-only` (fast), `standard` (default), `deep` (synthesis). Files good answers back to `wiki/questions/`.

→ `skills/wiki-query/SKILL.md`

---

## /wiki-lint

14-check health audit. Self-heals where safe. Writes report to `wiki/meta/lint-report-YYYY-MM-DD.md`.

Checks: orphans, dead links, stale claims, missing pages, missing cross-references, frontmatter gaps, empty sections, stale index entries, missing `summary:`, provenance drift, fragmented tag clusters, visibility/PII consistency, AI-writing tells, schema-version drift.

→ `skills/wiki-lint/SKILL.md`

---

## /wiki-status [delta|insights]

Two modes:
- `delta` (default) — what's pending in `.raw/` vs the manifest
- `insights` — graph health (anchor pages, bridges, surprising connections, suggested questions, graph delta)

→ `skills/wiki-status/SKILL.md`

---

## /cross-linker

Scored auto-link insertion. Runs after every ingest by default; manual invocation for full passes.

→ `skills/cross-linker/SKILL.md`

---

## /tag-taxonomy [audit|normalize|consult|add]

Single source of truth for tags is `wiki/meta/taxonomy.md`. Four modes:
- `audit` — report drift
- `normalize` — apply fixes
- `consult` — used by ingest at Step 5a
- `add` — propose new canonical tag

→ `skills/tag-taxonomy/SKILL.md`

---

## /wiki-rebuild [archive-only|rebuild|restore <ts>]

Three modes. Always archives FIRST to `.archive/<ISO>/`.

→ `skills/wiki-rebuild/SKILL.md`

---

## /wiki-export

Graph export to `_attachments/wiki-export/`: `graph.json` (NetworkX), `graph.graphml` (Gephi/Cytoscape), `cypher.txt` (Neo4j), `graph.html` (interactive vis.js viewer with filters).

→ `skills/wiki-export/SKILL.md`

---

## /humanize [page] | batch --pattern <p> | calibrate [--auto]

Rewrite synthesis prose to remove AI tells per `skills/wiki/references/writing-style.md`. Preserves frontmatter and wikilinks. Skips `source` pages.

→ `skills/humanize/SKILL.md`

---

## /publish-check (or /wiki-publish-check)

10-check pre-flight audit before pushing to a public repo.

→ `skills/wiki-publish-check/SKILL.md`

---

## /wiki-daily

Morning routine — context restore, status delta, insights, suggested actions.

→ `skills/wiki-daily/SKILL.md`

---

## /wiki-search [query]

Scale-up search for vaults > 200 pages. Optional BM25 (qmd) + vector + RRF. Grep fallback.

→ `skills/wiki-search/SKILL.md`

---

## /wiki-migrate from-<source> --path <vault>

Migration from: agrici, ar9av, obsidian (plain), notion, logseq, roam.

→ `skills/wiki-migrate/SKILL.md`

---

## Inherited utilities

| Command | Skill |
|---|---|
| `/save [name]` | `skills/save/` |
| `/autoresearch [topic]` | `skills/autoresearch/` |
| `/canvas [add image|text|pdf|note] ...` | `skills/canvas/` |
| `/defuddle [url]` | `skills/defuddle/` (used internally by `wiki-ingest` for URLs) |
