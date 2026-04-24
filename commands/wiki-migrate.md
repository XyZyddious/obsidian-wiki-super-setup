---
description: One-time migration from another knowledge-base system into this vault. Supports incoming migrations from agrici, ar9av, plain Obsidian, Notion, Logseq, and Roam.
---

Read the `wiki-migrate` skill (`skills/wiki-migrate/SKILL.md`). Then run the migration.

## Usage

- `/wiki-migrate from-agrici --path /path/to/agrici-vault`
- `/wiki-migrate from-ar9av --path /path/to/ar9av-vault`
- `/wiki-migrate from-obsidian --path /path/to/obsidian-vault`
- `/wiki-migrate from-notion --path /path/to/notion-export-dir`
- `/wiki-migrate from-logseq --path /path/to/logseq-vault`
- `/wiki-migrate from-roam --path /path/to/roam-export.json`

## Behavior

1. Pre-flight check: source path readable, target vault is empty enough to migrate into (warn if `wiki/` has > 10 user-authored pages).
2. Show migration plan: page count, source files, tags, conflicts. **REQUIRE explicit user approval** before proceeding.
3. Backup: `wiki-rebuild archive-only` first — non-negotiable.
4. Convert: source-specific transformation (see skill body). Apply universal frontmatter to every migrated page.
5. Tag normalization: collect all tags, run `tag-taxonomy consult`, batch-elicit decisions on new candidates.
6. Cross-link: full pass across all migrated pages.
7. Lint: surface findings, suggest follow-ups.
8. Report: pages migrated, pages skipped, conflicts resolved, tags added, lint findings.

## After migration

- Run `humanize batch --pattern vocabulary` on synthesis-heavy pages (old AI-generated content from previous tools).
- Run `wiki-status insights` to see the new graph shape.
- Run `wiki-publish-check` if planning to publish.
