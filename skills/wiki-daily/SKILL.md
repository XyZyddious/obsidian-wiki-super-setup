---
name: wiki-daily
description: Morning routine for the wiki. Reads hot.md, runs wiki-status (delta mode), runs wiki-status (insights mode if last >7 days), reports recent activity, surfaces flagged items from the most recent lint, and suggests next actions. Sets the user up to start the day with full context. Triggers on "/wiki-daily", "good morning", "what's on the wiki today", "morning check", "daily wiki", "what should I work on today", "where did I leave off".
---

# wiki-daily

Quick morning check on the wiki. Restores context, surfaces what's pending, suggests what to work on next. Designed to take ~30 seconds to read the output and decide where to focus.

## Workflow

### Step 1: Restore context (silent)

Read in this order:
1. `wiki/hot.md` — recent context (~500 words)
2. `wiki/index.md` — to know vault size
3. `wiki/log.md` — last 5-10 entries

### Step 2: Run delta check

Invoke `wiki-status` in delta mode. Get the count of NEW/MODIFIED/UNCHANGED sources in `.raw/`.

### Step 3: Conditional insights

Check `wiki/meta/insights.md` mtime. If older than 7 days OR doesn't exist, run `wiki-status insights`. Otherwise just read the existing report.

### Step 4: Recent lint check

Find the most recent `wiki/meta/lint-report-*.md`. If older than 14 days, suggest running `wiki-lint`. If recent, surface the count of HIGH and MEDIUM findings still pending.

### Step 5: Build the morning report

Print to chat (do NOT save as a file — this is ephemeral):

```
═══════════════════════════════════════════════════════════
  Morning check — 2026-04-23 09:00
═══════════════════════════════════════════════════════════

Vault: 312 pages | last touch: 2026-04-22 (yesterday)

Pending in .raw/:
  • 3 NEW sources
  • 1 MODIFIED source
  → Suggested: ingest append (4 sources, ~40 pages)

Insights (refreshed 2 days ago):
  Top hub: [[wiki/concepts/Retrieval Primitives]] (14 incoming)
  Bridge at risk: [[wiki/sources/karpathy-llm-wiki]]
  Tag drift: domain/research has cohesion 0.12 — consider cross-link

Lint (run 5 days ago):
  3 HIGH severity items pending
  12 MEDIUM (mostly orphans — cross-linker would help)
  → Report: [[wiki/meta/lint-report-2026-04-18]]

Open questions filed (last 7 days):
  [[wiki/questions/How does humanize calibrate?]]
  [[wiki/questions/Should I migrate from agrici?]]

Hot cache says you were last working on:
  "Q2 retrieval architecture decision — hybrid vector+BM25"

═══════════════════════════════════════════════════════════
  Today's suggested next actions:
  1. ingest append (4 sources pending)
  2. Review HIGH lint items (3 pending)
  3. Continue: write up the retrieval architecture decision
═══════════════════════════════════════════════════════════
```

### Step 6: Optional follow-up

If the user replies with a specific action ("let's ingest"), route directly to that skill. Otherwise wait.

## What this skill does NOT do

- Does NOT modify any files (read-only, ephemeral output)
- Does NOT run `wiki-lint` automatically (that's a heavier operation)
- Does NOT run `cross-linker` (only suggests it)
- Does NOT do the ingest itself (only suggests it)

## When NOT to run

- If you've already done a morning check today (check `wiki/log.md` for today's entries)
- In short focused work sessions where you don't need an overview
- For a vault with <10 pages (not enough signal yet)

## Cadence

- Daily, at the start of a work session
- Optional weekly variant (`wiki-daily --week`) shows trends over the past 7 days

## Reading list

1. `wiki/hot.md`
2. `wiki/index.md`
3. `wiki/log.md` (last 10 entries)
4. `wiki/meta/insights.md` (if exists)
5. Most recent `wiki/meta/lint-report-*.md` (if exists)

## Cross-skill integration

- Calls `wiki-status` (both modes)
- References (but does not run) `wiki-lint`, `cross-linker`, `wiki-ingest`
- Output mirrors the structure of `wiki/hot.md` — they complement each other (hot.md is yesterday's summary; this report is today's setup)
