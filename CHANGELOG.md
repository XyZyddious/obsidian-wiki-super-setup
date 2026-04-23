# Changelog

All notable changes to this vault's schema, skills, and tooling. The schema version in `wiki/overview.md` should match the latest entry here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning is semver-ish:

- **Major** — breaking changes to the universal frontmatter, vault layout, or skill spec
- **Minor** — new skill, new check, new convention added without breaking existing pages
- **Patch** — bug fix, documentation clarification, minor scaffolding tweak

Bump rule: when you edit `CLAUDE.md` substantively or add/remove skills, bump the version in `wiki/overview.md` and add an entry here. `wiki-lint` Check 14 detects drift.

---

## [2.0.0] — Initial release

The synthesized super-setup. Combines best-of from four upstream LLM-Wiki implementations (Karpathy, rohitg00, AgriciDaniel/claude-obsidian, Ar9av/obsidian-wiki — see `ATTRIBUTION.md`).

### Vault structure
- Three-layer ownership: `.raw/` (immutable sources) / `wiki/` (LLM-owned) / `CLAUDE.md` + skills (schema)
- 9 universal `wiki/` folders: concepts, entities, sources, comparisons, questions, references, projects, journal, misc
- `wiki/_raw/` for in-vault drafts staging
- `_templates/` with 8 page-type templates (source, entity, concept, comparison, question, project, decision, meeting)
- `_attachments/wiki-export/` for graph exports
- `.archive/` for snapshots before destructive ops

### Universal frontmatter (every page)
Required: `type`, `title`, `created`, `updated`, `tags` (≤5, canonical), `status`, `summary` (≤200 chars), `provenance` (extracted/inferred/ambiguous fractions), `confidence` (high/medium/low).

Optional: `related`, `sources`, `superseded_by`, `supersedes`.

System tags exempt from 5-tag cap: `visibility/public`, `visibility/internal`, `visibility/pii`.

### Provenance discipline
Inline markers: `^[inferred]` for synthesis, `^[ambiguous]` for sources disagree. Default (no marker) = extracted.

### 14 wiki skills
- `wiki` (orchestrator)
- `wiki-ingest` — source → 8-15 wiki pages, pauses to elicit new tag candidates via `AskUserQuestion`
- `wiki-query` — 4-tier retrieval ladder, 3 depths
- `wiki-lint` — 14 checks (8 structural + 4 quality + AI-writing tells + schema-version drift)
- `wiki-status` — delta + insights modes
- `cross-linker` — scored auto-link, optional `--emit-backlinks`
- `tag-taxonomy` — single source of truth, auto-invoked by ingest at Step 5a
- `wiki-rebuild` — archive-only / rebuild / restore
- `wiki-export` — JSON / GraphML / Cypher / interactive vis.js HTML
- `humanize` — rewrite prose to remove AI tells per `writing-style.md`, optional voice calibration
- `wiki-publish-check` — pre-flight audit before public push
- `wiki-daily` — morning routine
- `wiki-search` — optional BM25/qmd + vector for vaults > 200 pages
- `wiki-migrate` — incoming migration from agrici / ar9av / Obsidian / Notion / Logseq / Roam

### 6 inherited utility skills
`save`, `autoresearch`, `canvas`, `defuddle`, `obsidian-bases`, `obsidian-markdown`

### Multi-agent support (14 agents)
- **Tier 1** (formal bootstrap files): Claude Code, Codex CLI, OpenCode, Gemini CLI, Cursor, Windsurf, Kiro, Antigravity, GitHub Copilot
- **Tier 2** (spec-compatible via AGENTS.md): Aider, Hermes, OpenClaw, Kilocode, Trae

### Tooling
- `bin/start.sh` — single entry point for new forkers
- `bin/init-fork.sh` — interactive personalization
- `bin/setup-vault.sh` — Obsidian config (graph, snippets, app)
- `bin/setup-multi-agent.sh` — symlink `skills/` for non-Claude agents
- `bin/backup-vault.sh` — tarball + git-remote backup with retention
- `.github/workflows/lint.yml` — CI: manifest schema, frontmatter, skill spec, personal-info leaks, AI-writing scan
- `examples/` — 4 sample sources for testing the ingest workflow
- `wiki/meta/dashboard.base` — native Obsidian Bases dashboard (no Dataview required)
- `wiki/meta/dashboard.md` — Dataview dashboard (Dataview plugin required)

### Documentation
- `CLAUDE.md` — vault contract
- `WIKI.md` — full schema reference (10 sections)
- `README.md` — public-facing description
- `AGENTS.md` — multi-agent matrix
- `GEMINI.md` — Gemini CLI bootstrap
- `ATTRIBUTION.md` — credits to all four upstream sources
- `CONTRIBUTING.md` — PR conventions
- `CODE_OF_CONDUCT.md`, `SECURITY.md` — community standards
- `docs/install-guide.md`, `docs/plugins.md`, `docs/backup.md`, `docs/mcp-setup.md`

---

## Format for future entries

```markdown
## [VERSION] — YYYY-MM-DD

### Added
- New skill / convention / file

### Changed
- Behavior change / renamed thing

### Deprecated
- Will be removed in next major

### Removed
- Gone

### Fixed
- Bug fix

### Security
- Security-relevant change
```
