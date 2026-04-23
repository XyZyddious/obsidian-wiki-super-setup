---
name: wiki-migrate
description: Migration helpers for users coming to obsidian-wiki super setup from other systems. Supports incoming migrations from agrici/claude-obsidian, ar9av/obsidian-wiki, plain Obsidian vaults, Notion exports, Logseq exports, and Roam exports. Maps source format to the universal frontmatter (summary/provenance/confidence) and surfaces decisions the user needs to make. Use when user says "migrate from agrici", "import from notion", "convert this vault", "I have an existing vault", "wiki-migrate".
---

# wiki-migrate

One-time migration from other knowledge-base systems into the obsidian-wiki super setup format. Handles the common incoming migrations.

## Supported sources

| Source | Mode | What it migrates |
|---|---|---|
| `agrici` | `wiki-migrate from-agrici --path <vault>` | AgriciDaniel/claude-obsidian vaults — preserves wiki/, .raw/, _templates/, adds summary/provenance/confidence to existing pages |
| `ar9av` | `wiki-migrate from-ar9av --path <vault>` | Ar9av/obsidian-wiki vaults — most native compatibility, mainly normalizes folder structure (`_meta/` → `wiki/meta/`) |
| `obsidian` | `wiki-migrate from-obsidian --path <vault>` | Plain Obsidian vault — preserves notes, retrofits universal frontmatter, builds initial taxonomy from existing tags |
| `notion` | `wiki-migrate from-notion --path <export-dir>` | Notion HTML/Markdown export — converts page hierarchy to wiki/ folders, normalizes properties to frontmatter |
| `logseq` | `wiki-migrate from-logseq --path <vault>` | Logseq graph — block-based notes flattened to pages, journals/ → wiki/journal/ |
| `roam` | `wiki-migrate from-roam --path <export.json>` | Roam Research JSON export — pages converted, block refs collapsed to wikilinks |

## Universal workflow (all migrations)

1. **Pre-flight check**
   - Verify source path exists and is readable
   - Verify TARGET vault (this one) is empty enough to migrate into (warn if `wiki/` has >10 user-authored pages)
   - Estimate page count, source files, tags, and any potential conflicts (e.g. duplicate page names)

2. **Plan**
   - Show the user a migration plan: "I'll migrate N pages, M sources, K tags. Folder mapping: source/X → target/Y. Conflicts: list."
   - REQUIRE explicit approval before proceeding

3. **Backup**
   - Snapshot current target vault state to `.archive/pre-migration-<ISO>/` via `wiki-rebuild archive-only`
   - This is non-negotiable — migration is destructive enough to warrant always-backup

4. **Convert**
   - Source-specific transformation (see per-source sections below)
   - Apply universal frontmatter to every migrated page
   - For pages where original metadata is unclear, set defaults:
     - `provenance: {extracted: 1.0, inferred: 0.0, ambiguous: 0.0}` (assume original was authored by the user, treat as extracted)
     - `confidence: medium`
     - `status: developing`
   - Generate `summary:` for pages missing one — extract first paragraph or use title

5. **Tag normalization**
   - Collect all tags from the source vault
   - Run `tag-taxonomy consult` against `wiki/meta/taxonomy.md`
   - For tags not in canonical vocabulary, batch-elicit via `AskUserQuestion`
   - Apply normalizations across all migrated pages

6. **Cross-link**
   - Run `cross-linker` in full mode across all migrated pages
   - Builds the link graph from scratch on the new universal frontmatter

7. **Lint**
   - Run `wiki-lint` and surface findings
   - Most common: provenance drift on synthesis-heavy pages, missing summaries, AI-writing tells in old AI-generated content

8. **Report**
   - Pages migrated, pages skipped, conflicts resolved, tags added to taxonomy, lint findings
   - Suggest follow-ups: humanize batch on synthesis pages, manual review of conflicts

## Per-source notes

### `from-agrici` (AgriciDaniel/claude-obsidian)

- **Most compatible** — same parent fork as this vault.
- Preserves: `wiki/`, `.raw/`, `_templates/`, `wiki/hot.md`, `wiki/log.md`
- Adds: `summary` and `provenance` to every page (defaults: first paragraph as summary, extracted: 1.0)
- Preserves agrici-style frontmatter (`source_type`, `entity_type`, etc.) since they're spec-compatible
- Adds: `confidence: medium` defaults, `wiki/meta/taxonomy.md` seeded from existing tag usage
- Skips: agrici's `wiki/canvases/` (not a wiki concept; can be moved to `_attachments/` separately)
- Migrates: `bin/setup-vault.sh` config (graph.json, app.json) preserved if newer than current

### `from-ar9av` (Ar9av/obsidian-wiki)

- **Highest compatibility** — most concepts already match
- Folder rename: `_meta/` → `wiki/meta/` (the only major structural change)
- `_raw/` (in-vault) → `wiki/_raw/`
- `.raw/.manifest.json` schema bumps from ar9av's to ours (1-line schema field change)
- Cross-linker adapted to use our scoring (slightly different rules)
- Tag taxonomy preserved if ar9av had one; otherwise built from usage

### `from-obsidian` (plain Obsidian vault)

- **Most work** — vault has no wiki conventions to begin with
- Walk every `*.md`. For each:
  - Read existing frontmatter (if any) and YAML-tag block
  - Infer `type` from folder location and content (see heuristics below)
  - Generate `summary:` from first paragraph
  - Default `provenance: extracted: 1.0`, `confidence: medium`, `status: developing`
- Detect probable folder mappings:
  - `Concepts/` → `wiki/concepts/`
  - `People/`, `Companies/`, `Tools/` → `wiki/entities/`
  - `Daily Notes/`, `Journal/` → `wiki/journal/`
  - `Sources/`, `Articles/`, `Bookmarks/` → `wiki/sources/`
  - `Projects/` → `wiki/projects/`
  - Unknown → `wiki/misc/` (with affinity 0)
- Build `wiki/meta/taxonomy.md` from existing tag frequency (top 50 tags become canonical seed)

### `from-notion` (HTML or Markdown export)

- Notion's "Export as Markdown & CSV" gives a folder per database + Markdown for pages
- Map: each Notion database becomes a wiki folder (databases like "Tasks" → `wiki/projects/`)
- Properties (Notion's structured fields) → frontmatter
- `Created` and `Last Edited` properties → `created` and `updated`
- Internal Notion links (`/notion-id`) → resolve to `[[wikilinks]]` by page title
- Drop Notion-specific blocks (callouts: convert to Obsidian callout syntax; toggles: convert to details/summary)

### `from-logseq` (Logseq graph)

- Logseq is block-based; flatten blocks to paragraphs
- `pages/` → `wiki/concepts/` (most pages are conceptual)
- `journals/` → `wiki/journal/` with date-prefixed filenames
- Block references (`((block-id))`) → resolve to inline quotes with source attribution
- Logseq tags (with hashtag) → frontmatter `tags:` array
- Properties (`key:: value` syntax) → frontmatter

### `from-roam` (Roam JSON export)

- Roam's JSON is hierarchical — needs flattening
- Each top-level page becomes a wiki page
- Block hierarchies become nested headings (H2/H3/H4)
- Block refs (`((uid))`) → inline blockquote with source page link
- `[[Page]]` links preserve as wikilinks
- Daily notes folder → `wiki/journal/`

## What this skill does NOT do

- Does NOT delete the source vault — read-only
- Does NOT modify hooks, commands, or skills (those stay as the super-setup defaults)
- Does NOT do bidirectional sync — this is one-time migration only
- Does NOT migrate `.git/` history (start fresh git on the new vault)

## After migration

1. Review the migration report and resolve any conflicts
2. Run `humanize batch --pattern vocabulary` on synthesis-heavy pages (old AI-generated content from your previous tools is the most likely to have AI tells)
3. Run `wiki-status insights` to see the new graph shape
4. Run `wiki-publish-check` if planning to publish

## Reading list

1. The source vault's structure (varies per source)
2. `wiki/meta/taxonomy.md` (current target)
3. `CLAUDE.md` (for understanding the universal frontmatter spec)
