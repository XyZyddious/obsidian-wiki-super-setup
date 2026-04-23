# obsidian-wiki super setup — Install Guide

A persistent, compounding knowledge base for Obsidian. Synthesizes Karpathy + rohitg00 + AgriciDaniel/claude-obsidian + Ar9av/obsidian-wiki into one super-setup. Schema version 2.0.0.

---

## Prerequisites

| Tool | How to get it | Notes |
|---|---|---|
| **Obsidian** | https://obsidian.md | Free |
| **Claude Code** (or another Agent-Skills agent) | `npm install -g @anthropic-ai/claude-code` | Free tier available. Codex CLI, Cursor, Windsurf, Gemini CLI also supported. |
| **Git** | Pre-installed on most systems | Recommended for the auto-commit hook |

---

## Installation

### One command (recommended)

After cloning, run:

```bash
cd /path/to/this/vault
bash bin/start.sh
```

This is the single entry point. It walks you through:

1. **Personalizing the fork** (`init-fork.sh`) — your name as the local copyright holder, git user.name/email, optional voice sample for `humanize`, optional content reset for clean-slate start
2. **Configuring Obsidian** (`setup-vault.sh`) — graph view, color CSS snippets, app config, Excalidraw plugin
3. **Multi-agent setup** (`setup-multi-agent.sh`, optional) — symlinks `skills/` for Codex / OpenCode / Cursor / Windsurf / Gemini CLI

Idempotent — re-running skips completed steps. Use this command on first install AND after any major changes.

### Manual installation (if you want full control)

Run each script directly:

```bash
bash bin/init-fork.sh         # personalize
bash bin/setup-vault.sh       # Obsidian config
bash bin/setup-multi-agent.sh # symlink skills for non-Claude agents
```

### Multi-agent support (14 agents)

`setup-multi-agent.sh` wires up skill discovery for:

- **Tier 1** (formal bootstrap in repo): Claude Code, Codex CLI, OpenCode, Gemini CLI, Cursor, Windsurf, Kiro, Antigravity, GitHub Copilot
- **Tier 2** (uses `AGENTS.md` natively): Aider, Hermes, OpenClaw, Kilocode, Trae

The script symlinks `skills/` into each agent's expected location (e.g. `~/.codex/skills/obsidian-wiki` for Codex). Idempotent — only adds symlinks for agents that don't already have one. See [AGENTS.md](../AGENTS.md) for the full matrix.

### After installation

1. **Open the vault** in Obsidian: Manage Vaults → Open folder as vault → select this directory.
2. **Open Claude Code** (or your Agent Skills client).
3. **Type `/wiki`** to verify setup.
4. **Drop a source** into `.raw/` and run `ingest <filename>`.

---

## What you get out of the box

### Vault structure

```
.raw/                IMMUTABLE source dump (hidden in Obsidian)
.archive/            Snapshots before destructive ops
_attachments/        Images, PDFs, exported graphs
_templates/          8 universal-frontmatter templates
wiki/                LLM-OWNED knowledge base
  index.md, hot.md, log.md, overview.md
  meta/{taxonomy.md, insights.md, dashboard.md}
  concepts/, entities/, sources/, comparisons/, questions/,
  references/, projects/, journal/, misc/, _raw/
skills/              14 wiki skills + 6 utilities
```

### 14 wiki skills

| Skill | What it does |
|---|---|
| `wiki` | Orchestrator. Routes to sub-skills. |
| `wiki-ingest` | Source → 8-15 wiki pages. PAUSES to ask about new tag candidates via AskUserQuestion. Auto-runs cross-linker. |
| `wiki-query` | 4-tier retrieval ladder. Three depths (index-only / standard / deep). |
| `wiki-lint` | 14 checks, self-healing where safe. Flags AI-writing tells for `humanize`; flags schema-version drift. |
| `wiki-status` | Delta report + insights mode (hubs/bridges/gaps). |
| `cross-linker` | Scored auto-link insertion. |
| `tag-taxonomy` | Audit / normalize / consult / add canonical tags. |
| `wiki-rebuild` | Archive-only / archive+rebuild / restore. |
| `wiki-export` | Graph export (JSON/GraphML/Cypher/HTML). |
| `humanize` | Rewrite synthesis prose to remove AI tells per `writing-style.md`. Optional auto voice calibration. |
| `wiki-publish-check` | Pre-flight audit before pushing to a public repo. |
| `wiki-daily` | Morning routine — context, status, suggested actions. |
| `wiki-search` | Optional BM25/qmd search for vaults > 200 pages. |
| `wiki-migrate` | Migration from agrici / ar9av / Obsidian / Notion / Logseq / Roam. |

Plus utilities: `save`, `autoresearch`, `canvas`, `defuddle`, `obsidian-bases`, `obsidian-markdown`.

---

## First-time workflow

1. **Open the vault** in Obsidian: Manage Vaults → Open folder as vault → select this directory.
2. **Open Claude Code** (or your agent) in the same directory.
3. **Read `CLAUDE.md`** — the vault contract.
4. **Drop a source** into `.raw/` (any format: markdown, PDF, txt, image, transcript).
5. **Ingest**: say `ingest <filename>` (or `ingest all of these` for batches).
   - Claude reads under the content-trust boundary
   - Extracts entities/concepts/claims with provenance markers
   - **Pauses to ask about new tag candidates** (you don't edit `taxonomy.md` by hand)
   - Creates 8-15 pages with full frontmatter
   - Runs `cross-linker` automatically
6. **Ask a question**: just ask. Claude reads the index first, then drills into pages, cites them.
7. **Maintain**:
   - `lint the wiki` every 10-15 ingests
   - `wiki status` weekly to see what's pending
   - `wiki insights` weekly for graph health
   - `export the wiki graph` monthly for archive/sharing

---

## Frontmatter discipline

Every page carries:

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

Plus type-specific extensions. Full spec: `skills/wiki/references/frontmatter.md`.

---

## Visibility & PII

- `visibility/public` (default), `visibility/internal`, `visibility/pii` are SYSTEM tags exempt from the 5-tag cap.
- `wiki-lint` Check 12 scans page bodies for PII patterns (passwords, API keys, tokens, emails) and flags pages without proper visibility tags.
- `wiki-export` defaults to `visibility/public` only. The `--all` flag overrides with a loud warning.

---

## Optional Obsidian plugins

These add nice features but the vault works without them:

| Plugin | What it adds |
|---|---|
| **Dataview** | Renders the queries in `wiki/meta/dashboard.md` |
| **Templater** | Auto-fills frontmatter when creating new pages from `_templates/` |
| **Obsidian Bases** | Renders the `dashboard.base` if you migrate to native Bases |
| **Calendar** | Sidebar calendar with word count + task dots |
| **Banners** | Add `banner:` to frontmatter for header images |
| **Excalidraw** | Freehand drawing (downloaded by `setup-vault.sh`) |

---

## Cross-project access

To reference this wiki from another project (a code repo, another vault), add to that project's `CLAUDE.md`:

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

## Troubleshooting

| Symptom | Fix |
|---|---|
| `/wiki` says "not found" | The plugin manifest is at `.claude-plugin/plugin.json`. In Claude Code: open the project, type `/wiki`. The skills directory should auto-load. |
| Custom callouts don't render | Enable `vault-colors` CSS snippet: Settings → Appearance → CSS snippets. |
| Hot cache not loading at session start | Known Claude Code bug `anthropics/claude-code#10875`. See `hooks/README.md` for the workaround. |
| Tag elicitation skipped | Make sure your agent supports `AskUserQuestion`. If not, the skill falls back to writing all candidates to `taxonomy.md` with `_pending/` prefix for manual review. |
| Lint flags too many provenance-drift findings | You probably skipped applying inline `^[inferred]` markers. Either add them or update the `provenance:` block fractions. |

---

## Maintenance cadence

| Frequency | Operation |
|---|---|
| After every ingest | `cross-linker` (automatic) |
| Every 10-15 ingests | `lint the wiki` |
| Weekly | `wiki status` + `wiki insights` |
| Monthly | `wiki export` |
| When schema evolves | Edit `CLAUDE.md` deliberately + bump version note in `wiki/overview.md` |

---

## Getting help

- `CLAUDE.md` — vault contract
- `WIKI.md` — full schema reference
- `README.md` — vault description
- `ATTRIBUTION.md` — credits to the four source patterns
- `skills/wiki/SKILL.md` — orchestrator (read for routing)
- `skills/wiki/references/frontmatter.md` — frontmatter spec
