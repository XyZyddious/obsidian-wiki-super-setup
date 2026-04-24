---
description: Morning routine for the wiki — restore context from hot.md, run wiki-status delta, conditionally run insights, surface lint findings, suggest next actions. Read-only ephemeral report.
---

Read the `wiki-daily` skill (`skills/wiki-daily/SKILL.md`). Then run the morning workflow.

## Usage

- `/wiki-daily` — full morning check (default)
- `/wiki-daily --week` — weekly variant; show 7-day trends instead of single-day delta

## Behavior

1. If no vault is set up, say: "No wiki vault found. Run `/wiki` first to set one up."
2. Silently restore context: read `wiki/hot.md`, `wiki/index.md`, last 10 entries of `wiki/log.md`.
3. Run `wiki-status` in delta mode to count NEW/MODIFIED sources in `.raw/`.
4. Check `wiki/meta/insights.md` mtime; if > 7 days old (or missing), run `wiki-status insights`.
5. Find most recent `wiki/meta/lint-report-*.md`; if > 14 days, suggest running `wiki-lint`.
6. Print the morning report (do NOT save to a file — output is ephemeral).
7. Wait for the user's response. Don't auto-execute suggested actions.
