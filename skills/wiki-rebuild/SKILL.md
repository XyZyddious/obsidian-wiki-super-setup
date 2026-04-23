---
name: wiki-rebuild
description: Three-mode destructive operation. "archive-only" snapshots the current wiki to .archive/<ISO>/. "rebuild" archives THEN re-ingests everything from .raw/. "restore <timestamp>" restores from a prior archive. Use when user says "rebuild the wiki", "archive the wiki", "restore the wiki", "reset and re-ingest".
---

# wiki-rebuild

Destructive operations require an archive-first discipline. This skill enforces that.

## Core principle: archive before destroy

**Every destructive operation in this skill writes a complete snapshot to `.archive/<ISO-timestamp>/` FIRST, with `archive-meta.json`, BEFORE touching anything else.** No exceptions.

If the archive write fails, abort the entire operation.

---

## Modes

### `archive-only`

Snapshots the current state of the vault without modifying anything else.

#### Workflow

1. Generate timestamp: `YYYY-MM-DDTHHMMSSZ` (UTC).
2. Create `.archive/<timestamp>/`.
3. Copy:
   - `wiki/` → `.archive/<timestamp>/wiki/`
   - `_templates/` → `.archive/<timestamp>/_templates/`
   - `.raw/.manifest.json` → `.archive/<timestamp>/.manifest.json`
   - `CLAUDE.md` → `.archive/<timestamp>/CLAUDE.md`
   - `skills/wiki-ingest/SKILL.md`, `skills/wiki-query/SKILL.md`, `skills/wiki-lint/SKILL.md`, etc. (the wiki skills) → `.archive/<timestamp>/skills/`
4. Write `.archive/<timestamp>/archive-meta.json`:

```json
{
  "archived_at": "<ISO timestamp>",
  "reason": "<user-supplied or 'manual archive-only'>",
  "operator": "<user> via Claude",
  "schema_version": "1.0",
  "vault_state": {
    "total_pages": N,
    "total_sources_in_raw": M,
    "manifest_hash": "<sha256 of .raw/.manifest.json>"
  },
  "contents": {
    "wiki": "full snapshot",
    "_templates": "all 8 templates",
    "manifest": "ingest manifest",
    "CLAUDE.md": "vault contract (the schema doc)",
    "skills": "wiki skill bodies (NOT the .raw/ contents — those are the source of truth)"
  },
  "restore_instructions": "Use `wiki-rebuild restore <timestamp>` or manually copy contents back to vault root."
}
```

5. Append to `wiki/log.md`:

```markdown
## [YYYY-MM-DD HH:MM] archive | manual snapshot
- archive: .archive/<timestamp>/
- vault_pages: N
- size: X MB
- reason: <reason>
```

6. Report completion.

### `rebuild` (archive + full re-ingest)

The destructive one. Archives, then wipes the LLM-owned content, then re-ingests from `.raw/`.

#### Workflow

1. **CONFIRM** with user: "This will archive the current wiki to `.archive/<timestamp>/` then wipe and re-ingest. Proceed?" REQUIRE explicit yes.
2. Run `archive-only` mode first. Verify success.
3. Wipe (preserve scaffolding):
   - `wiki/sources/` (delete contents, keep folder + `_index.md`)
   - `wiki/concepts/` (delete contents, keep folder + `_index.md`)
   - `wiki/entities/` (delete contents, keep folder + `_index.md`)
   - `wiki/comparisons/` (delete contents, keep folder + `_index.md`)
   - `wiki/questions/` (delete contents, keep folder + `_index.md`)
   - `wiki/journal/` (delete contents, keep folder + `_index.md`)
   - **PRESERVE**: `wiki/index.md`, `wiki/hot.md`, `wiki/log.md`, `wiki/overview.md`, `wiki/meta/*`, `wiki/projects/*` (project content is special), `wiki/references/*`, `wiki/misc/*`
4. Reset `.raw/.manifest.json`:
   - Keep `version`, `schema`, `projects`, `_schema_doc`
   - Reset `sources` to `{}`, `stats.total_sources_ingested` to 0, `stats.total_pages` to 0
   - Set `stats.last_full_rebuild` to now
5. Run `wiki-ingest` in `full` mode against everything in `.raw/`.
6. After all ingests, run `cross-linker` in full mode.
7. Run `wiki-lint` and write the report.
8. Update `wiki/index.md` with fresh hub/recent sections via `wiki-status insights`.
9. Append to `wiki/log.md`:

```markdown
## [YYYY-MM-DD HH:MM] rebuild | full
- archive: .archive/<timestamp>/
- pages_before: N | pages_after: M
- sources_processed: K
- duration: T minutes
- post-rebuild lint: [[wiki/meta/lint-report-...]]
```

### `restore <timestamp>`

Restore from a prior archive.

#### Workflow

1. Verify `.archive/<timestamp>/archive-meta.json` exists.
2. **CONFIRM** with user: "Restore from `<timestamp>`? This will FIRST archive the current state to a new `.archive/<new-timestamp>/`, THEN restore the old snapshot. Proceed?" REQUIRE explicit yes.
3. Archive the CURRENT state with `archive-only` mode and a `restore-from-<timestamp>` reason. (Belt and suspenders.)
4. Restore from the source archive:
   - Copy `.archive/<timestamp>/wiki/` → `wiki/` (overwrite)
   - Copy `.archive/<timestamp>/_templates/` → `_templates/`
   - Copy `.archive/<timestamp>/.manifest.json` → `.raw/.manifest.json`
   - Copy `.archive/<timestamp>/CLAUDE.md` → `CLAUDE.md` (only with explicit user approval — they may have intentionally evolved it)
   - Copy `.archive/<timestamp>/skills/` → `skills/` (only with explicit user approval — same reasoning)
5. Append to `wiki/log.md`:

```markdown
## [YYYY-MM-DD HH:MM] restore | from <timestamp>
- restored_from: .archive/<timestamp>/
- safety_archive: .archive/<new-timestamp>/
- pages_restored: N
- restored_skills: yes|no
- restored_CLAUDE.md: yes|no
```

---

## Listing archives

`wiki-rebuild list` (or just `list archives`):

```
Available archives:
  <ISO-timestamp>    <reason-tag>  <size>  <page-count>  reason: "<free-text reason>"
  <ISO-timestamp>    <reason-tag>  <size>  <page-count>  reason: "<free-text reason>"
```

---

## What never gets touched

Even in full rebuild:
- `.raw/` itself — sources are the input, never wiped by this skill
- `.obsidian/` — user's Obsidian config
- `.claude-plugin/`, `.git/`, `bin/`, `docs/`, `hooks/`, `commands/`, `agents/` — not LLM-content

If the user wants to nuke `.raw/` too, they do it manually.

---

## Reading list before any operation

1. `CLAUDE.md`
2. `.raw/.manifest.json`
3. The current state of `wiki/` (just to know what's about to be archived)
