---
description: Pre-flight 10-check audit before pushing to a public repo. Scans for personal info, complete frontmatter, _pending tags, AI-writing callouts, orphans, visibility leaks, schema-version drift, doc consistency. Produces READY TO PUBLISH or FIX THESE FIRST report.
---

Read the `wiki-publish-check` skill (`skills/wiki-publish-check/SKILL.md`). Then run the audit.

## Usage

- `/wiki-publish-check` — full publish-readiness audit
- `/publish-check` — alias

## Behavior

1. Read `CLAUDE.md`, `WIKI.md`, `wiki/overview.md`, `wiki/meta/taxonomy.md`.
2. Run all 10 checks:
   - **Critical** (4): personal-info patterns, visibility-flagged pages, required frontmatter complete, no `_pending/` tags
   - **Important** (4): no `[!ai-writing]` callouts pending, no orphans, no stale superseded pages, schema version fresh
   - **Cosmetic** (2): documentation consistency (skill/lint counts match filesystem), recent activity (log entry within 30 days)
3. If any critical check fails → `FIX THESE FIRST` report and exit 1.
4. If only important/cosmetic findings → `READY WITH WARNINGS` report.
5. If all pass → `READY TO PUBLISH` report.
6. Output is ephemeral — do NOT save a report file.
