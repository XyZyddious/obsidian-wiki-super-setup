# Claude-Obsidian Super Setup

> Synthesized and maintained by [@XyZyddious](https://github.com/XyZyddious).

A persistent, compounding knowledge vault for Claude + Obsidian. Synthesized from the four leading LLM-Wiki implementations:

- **[Karpathy's LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)** — the seed pattern: three-layer architecture, `index.md`, `log.md`, "compounding artifact" framing.
- **[rohitg00 v2 gist](https://gist.github.com/rohitg00/2067ab416f7bbe447c1977edaaa681e2)** — production patterns: confidence scoring, supersession, decay, self-healing lint, audit trail.
- **[AgriciDaniel/claude-obsidian](https://github.com/AgriciDaniel/claude-obsidian)** — concrete vault layout, `.raw/` discipline, hot cache, custom callouts, three-depth query, 8-check lint.
- **[Ar9av/obsidian-wiki](https://github.com/Ar9av/obsidian-wiki)** — `summary:` frontmatter, provenance markers, retrieval-primitives ladder, cross-linker, tag taxonomy, wiki-status insights, content-trust boundary.

What you get: a knowledge base that gets richer every time you add a source or ask a question, with built-in maintenance, provenance discipline, and graph-aware insights.

> **The wiki is the product. Chat is just the interface.** Every answer is filed. Every claim cites a source. Every page knows how confident it is.

---

## What it does

- **Drop a source** into `.raw/`, say `ingest [filename]`. Claude reads it under a content-trust boundary, extracts entities/concepts/claims, creates 8-15 wiki pages with `summary:` + `provenance:` frontmatter, updates the index, runs the cross-linker.
- **Ask a question.** Claude reads `hot.md` (recent context), the index, then climbs a 4-tier retrieval ladder (frontmatter grep → `summary:` → sectioned grep → full read). Cites specific pages. Files good answers back to `wiki/questions/`.
- **Lint.** 14 checks: orphans, dead links, stale claims, missing pages, missing cross-references, frontmatter gaps, empty sections, stale index entries, missing `summary:`, provenance drift, fragmented tag clusters, visibility/PII consistency, AI-writing tells, schema-version drift. Self-heals where safe; flags rest for `humanize`.
- **Insights.** Anchor pages, bridge pages, tag cohesion, surprising connections, suggested questions, graph delta — written to `wiki/meta/insights.md`.
- **Cross-link.** Scored auto-link with EXTRACTED/INFERRED/AMBIGUOUS confidence. Runs after every ingest.
- **Tag taxonomy.** Single source of truth in `wiki/meta/taxonomy.md`. Audit, normalize, consult on new pages, propose new canonical tags.
- **Rebuild.** Archive → wipe → re-ingest from `.raw/`. Snapshots to `.archive/<ISO>/` first, always.
- **Export.** Wikilink graph to `graph.json` (NetworkX), `graph.graphml` (Gephi/Cytoscape), `cypher.txt` (Neo4j), `graph.html` (self-contained vis.js viewer).
- **Humanize.** Rewrite synthesis prose to remove AI tells (significance inflation, AI vocabulary, em-dash overuse, "not just X but Y", inline-bolded lists, filler, etc.) per a synthesized writing-style guide. Single-page or batch by pattern. Optional voice calibration (manual paste or auto-sample from existing user content).
- **Publish-check, daily, search, migrate.** Quality-of-life skills — pre-publish audits, morning routine, scale-up search, migration from other knowledge-base systems.

---

## Architecture (six layers)

```
.raw/                 IMMUTABLE source dump (hidden in Obsidian)
.archive/             Snapshots before destructive ops
_attachments/         Images, PDFs, exported graphs
_templates/           Universal-frontmatter templates
wiki/                 LLM-OWNED knowledge base
  index.md            Master catalog
  hot.md              Session bridge (~500 words)
  log.md              Append-only operation journal
  overview.md         Vault executive summary
  meta/
    taxonomy.md       Canonical tag vocabulary
    insights.md       Auto-generated graph health
    dashboard.md      Dataview / Bases dashboard
  concepts/, entities/, sources/, comparisons/, questions/,
  references/, projects/, journal/, misc/, _raw/
skills/               How Claude operates the vault (14 skills, see below)
```

Read `CLAUDE.md` for the full contract.

---

## The 14 wiki skills

| Skill | What it does | When to invoke |
|---|---|---|
| [`wiki`](skills/wiki/SKILL.md) | Orchestrator. Routes to sub-skills. Setup check. | `/wiki` |
| [`wiki-ingest`](skills/wiki-ingest/SKILL.md) | Source → 8-15 wiki pages with summary + provenance. Three modes (append/full/raw). Auto-runs cross-linker. | `ingest [file]` |
| [`wiki-query`](skills/wiki-query/SKILL.md) | Retrieval-ladder query. Three modes (index-only/standard/deep). File-back pattern. | Any question |
| [`wiki-lint`](skills/wiki-lint/SKILL.md) | 14-check audit, self-healing, report to `wiki/meta/`. | `lint the wiki` |
| [`wiki-status`](skills/wiki-status/SKILL.md) | Delta report + insights mode (hubs/bridges/gaps). | `wiki status`, `wiki insights` |
| [`cross-linker`](skills/cross-linker/SKILL.md) | Scored auto-link. Run after every ingest. | `cross-link` |
| [`tag-taxonomy`](skills/tag-taxonomy/SKILL.md) | Audit / normalize / consult / add — against `wiki/meta/taxonomy.md`. Asks you about new tags during ingest. | `audit tags`, runs during ingest |
| [`wiki-rebuild`](skills/wiki-rebuild/SKILL.md) | Archive-only / archive+rebuild / restore. | `rebuild`, `archive`, `restore <ts>` |
| [`wiki-export`](skills/wiki-export/SKILL.md) | Graph export (JSON/GraphML/Cypher/HTML). Visibility-aware. | `export the wiki` |
| [`humanize`](skills/humanize/SKILL.md) | Rewrite synthesis prose to remove AI tells per the writing-style guide. Single-page or batch by pattern. Optional auto voice calibration. | `humanize <page>`, `humanize batch` |
| [`wiki-publish-check`](skills/wiki-publish-check/SKILL.md) | Pre-flight audit before pushing to a public repo — PII, frontmatter, AI tells, orphans, visibility leaks. | `publish-check` |
| [`wiki-daily`](skills/wiki-daily/SKILL.md) | Morning routine — context restore, status delta, insights, suggested actions. Read-only ephemeral report. | `wiki-daily`, "good morning" |
| [`wiki-search`](skills/wiki-search/SKILL.md) | Scale-up search for vaults > 200 pages. Optional BM25 (qmd) + vector + RRF. Grep fallback. | `wiki-search <query>` |
| [`wiki-migrate`](skills/wiki-migrate/SKILL.md) | Migration from agrici / ar9av / Obsidian / Notion / Logseq / Roam. | `wiki-migrate from-<source>` |

Plus inherited skills: `autoresearch`, `canvas`, `save`, `defuddle`, `obsidian-bases`, `obsidian-markdown`.

---

## Frontmatter discipline (every page)

```yaml
type: source|entity|concept|comparison|question|project|decision|meeting|journal|reference|meta
title: "Human-Readable Title"
created: 2026-04-23
updated: 2026-04-23
tags: [domain, type]              # max 5; canonical from wiki/meta/taxonomy.md
status: seed|developing|mature|evergreen|superseded
summary: >-                       # ≤200 chars — load-bearing for cheap retrieval
  One or two sentences a reader can preview without opening the page.
provenance:                       # rough fractions summing to ~1.0
  extracted: 0.72                 # directly from source (no marker)
  inferred: 0.25                  # synthesis (^[inferred] inline)
  ambiguous: 0.03                 # sources disagree (^[ambiguous] inline)
confidence: high|medium|low
```

Plus type-specific extensions and optional `superseded_by` / `supersedes`. Full spec: [`skills/wiki/references/frontmatter.md`](skills/wiki/references/frontmatter.md).

### Provenance markers (in body, not frontmatter)

- No marker = EXTRACTED (default)
- `^[inferred]` = your synthesis or extrapolation
- `^[ambiguous]` = sources disagree, or you're uncertain

`wiki-lint` recomputes the frontmatter fractions periodically and flags drift > 0.20.

### Visibility (system tags — exempt from 5-tag cap)

`visibility/public` (default), `visibility/internal`, `visibility/pii`. `wiki-export` defaults to public-only.

---

## Quick start

After cloning, run **one command**:

```bash
bash bin/start.sh
```

This is the single entry point. It detects what's already done and runs the rest in order:

1. `bin/init-fork.sh` — personalize your fork (replaces placeholder author with your name, sets git config, optionally seeds a voice sample for `humanize`)
2. `bin/setup-vault.sh` — configures Obsidian (graph view, color snippets, app config, downloads Excalidraw if needed)
3. (optional) `bin/setup-multi-agent.sh` — symlinks `skills/` for Codex CLI / OpenCode / Cursor / Windsurf / Gemini CLI

Idempotent — safe to re-run. Skips any step already complete.

After that:

1. **Open the vault** in Obsidian: Manage Vaults → Open folder as vault → select this directory.
2. **Open Claude Code** (or another Agent Skills client) in the same directory.
3. **Type `/wiki`** to verify everything is wired up.
4. **Test the workflow** — drop a sample into `.raw/`:
   ```bash
   cp examples/article.md .raw/
   ```
   Then in Claude Code: `ingest .raw/article.md`. Watch Claude pause to ask about new tags, create 8-15 wiki pages, and run cross-linker.
5. **Ask a question**: just ask. Claude reads the index first, drills into pages, cites them.
6. **Maintain**: `wiki-daily` mornings, `lint the wiki` every 10-15 ingests, `wiki status` weekly.

When ready to publish your fork to GitHub:

```bash
# (in Claude Code) publish-check          ← audit publish-readiness
bash bin/backup-vault.sh                  ← one-time backup of clean state
git add . && git commit -m "Initial commit"
git push
```

---

## Maintenance cadence

| Cadence | Operation |
|---|---|
| After every ingest | `cross-linker` (automatic) |
| Every 10-15 ingests | `lint the wiki` |
| Weekly | `wiki status` (delta), `wiki insights` (graph health) |
| Monthly | `wiki export` (graph snapshot) |
| When schema evolves | Edit `CLAUDE.md` deliberately |

---

## Multi-agent support

The vault works with 14 agents through the cross-platform Agent Skills standard:

**Tier 1 — formal bootstrap files in the repo:**
Claude Code, Codex CLI, OpenCode, Gemini CLI, Cursor, Windsurf, Kiro, Antigravity, GitHub Copilot (VS Code)

**Tier 2 — spec-compatible (uses `AGENTS.md` natively):**
Aider, Hermes, OpenClaw, Kilocode, Trae

Run `bash bin/setup-multi-agent.sh` to wire up skill discovery for whichever ones you have installed. See [AGENTS.md](AGENTS.md) for the full matrix.

## Cross-project access

To reference this wiki from another Claude Code project, add to that project's `CLAUDE.md`:

```markdown
## Wiki Knowledge Base
Path: /path/to/this/vault

Read in this order, only as needed:
1. wiki/hot.md (recent context, ~500 words)
2. wiki/index.md (master catalog)
3. wiki/<category>/_index.md (sub-index)
4. Individual wiki pages

Don't read the wiki for general coding questions or things already in this project.
```

---

## Layout summary

```
CLAUDE.md             The contract (read first)
README.md             This file
WIKI.md               Schema reference (deep dive)
ATTRIBUTION.md        Sources and credits
LICENSE               MIT
.raw/                 Drop sources here
.archive/             Snapshots before destructive ops
_attachments/         Images, PDFs, graph exports
_templates/           8 templates (source/entity/concept/comparison/question/project/decision/meeting)
wiki/                 LLM-owned content
skills/               9 wiki-* skills + 6 inherited
```

---

## Attribution

This synthesis would not exist without:

- **Andrej Karpathy** — the original LLM Wiki gist that named the pattern.
- **rohitg00** — production-pattern v2 gist (confidence, supersession, decay, self-healing).
- **AgriciDaniel** — `claude-obsidian` plugin (vault layout, `.raw/` discipline, hot cache, callouts, lint, dashboards).
- **Ar9av** — `obsidian-wiki` (summary, provenance, retrieval ladder, cross-linker, tag-taxonomy, insights, content-trust boundary).

See `ATTRIBUTION.md` for the full credits.

License: MIT.
