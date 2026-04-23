---
name: wiki-publish-check
description: Audit the vault for publish readiness before pushing to a public repo or sharing externally. Checks personal-info leaks, complete frontmatter, no _pending tags from incomplete elicitation, no [!ai-writing] callouts pending humanization, no orphan pages, no visibility/internal or visibility/pii pages slipping through, schema-version freshness, and a few more publishing concerns. Produces a one-page READY TO PUBLISH or FIX THESE FIRST report. Use when the user says "publish check", "is the vault ready to publish", "publish-ready audit", "pre-flight check", "ready to share", "ready for github".
---

# wiki-publish-check

Pre-flight audit before pushing the vault to a public repo or sharing it. More opinionated than `wiki-lint` — designed to answer one question: **is this safe and complete to make public right now?**

## When to run

- Before `git push origin main` to a public repo for the first time
- Before publishing a fork as a template for others
- Before sending the vault to a collaborator
- Before any `wiki-export --all` (which would include internal/pii pages)
- Periodically as part of release hygiene

## The 10 publish-readiness checks

### Critical (must pass — would block publishing)

1. **Personal info patterns** — grep for known PII patterns across vault (excluding `.git/`, `.obsidian/`, `.archive/`):
   - Email addresses with non-noreply domains (`@gmail`, `@outlook`, `@yahoo`, `@<company>`)
   - Hostnames (`*.local`, machine names like `<your-name>s-MacBook-Pro`)
   - Real first/last names not in attribution context
   - API keys (`sk-`, `pk-`, `eyJ`, `ghp_`, etc.), passwords, tokens, secrets
   - Phone numbers, SSNs, credit-card patterns

2. **Visibility/PII pages present** — any page tagged `visibility/internal` or `visibility/pii`. These would leak in `wiki-export --all` and shouldn't ship in a published vault. Recommend either: remove, redact, or move to `.archive/` for local-only retention.

3. **Required frontmatter complete** — every wiki page has `type`, `title`, `created`, `updated`, `tags`, `status`, `summary`, `provenance`, `confidence`. Templates too.

4. **`_pending/` tags from incomplete elicitation** — any page still has `_pending/<candidate>` placeholder tags from an interrupted ingest. The user must finish tag elicitation before publishing.

### Important (should pass — strongly recommended)

5. **`[!ai-writing]` callouts pending** — pages flagged by `wiki-lint` Check 13 that haven't been humanized. Recommend running `humanize batch --scope flagged-by-lint`.

6. **Orphan pages** — pages with 0 incoming wikilinks. Public vaults benefit from full connectivity. Recommend running `cross-linker` or removing orphans.

7. **`status: superseded` pages stale** — pages stuck in superseded for >180 days. Either archive or restore.

8. **Schema-version freshness** — `wiki/overview.md` schema version matches `CLAUDE.md` last-modified state. If `CLAUDE.md` was edited more recently than `overview.md`'s version note bumped, flag.

### Cosmetic (warnings only)

9. **Documentation consistency** — counts of skills, lint checks, templates in CLAUDE.md, README.md, WIKI.md, AGENTS.md, GEMINI.md should match actual filesystem state. Drift here is the most common publishing error.

10. **`wiki/log.md` newest entry within 30 days** — if vault hasn't been touched in over a month, surface that in the report so user can update before publishing.

## Workflow

1. Read `CLAUDE.md`, `WIKI.md`, `wiki/overview.md`, `wiki/meta/taxonomy.md`.
2. Run all 10 checks. Collect findings as `{check_id, severity, page, detail, fix}`.
3. If ANY critical check fails → produce **FIX THESE FIRST** report and exit code 1.
4. If only important/cosmetic checks have findings → produce **READY WITH WARNINGS** report.
5. If everything passes → produce **READY TO PUBLISH** report.

## Output

Always print to chat. Do NOT write a persistent report file (this is ephemeral, intended for one-off pre-publish checks).

Format:

```
═══════════════════════════════════════════════════════════
  PUBLISH-READINESS REPORT — 2026-04-23 09:00
═══════════════════════════════════════════════════════════

Status: READY TO PUBLISH | READY WITH WARNINGS | FIX THESE FIRST

CRITICAL (3 checks):
  ✓ No personal info patterns
  ✓ No visibility/internal or visibility/pii pages
  ✗ 2 pages missing required frontmatter:
      [[wiki/concepts/Untitled]] — missing summary, confidence
      [[wiki/sources/quick-note]] — missing provenance
  ✓ No _pending/ tags

IMPORTANT (4 checks):
  ⚠ 3 [!ai-writing] callouts pending — run `humanize batch --scope flagged-by-lint`
  ✓ No orphan pages
  ✓ No stale superseded pages
  ✓ Schema version fresh

COSMETIC (2 checks):
  ⚠ Documentation drift detected:
      README.md says "12 checks" but wiki-lint has 13
      AGENTS.md says "9 wiki skills" but skills/ has 10
  ✓ Recent activity (last log entry: 2026-04-23)

═══════════════════════════════════════════════════════════
  Recommendations:
  1. Fix the 2 frontmatter gaps (highest priority)
  2. Run `humanize batch --scope flagged-by-lint`
  3. Reconcile doc drift before publishing
═══════════════════════════════════════════════════════════
```

## Reading list before running

1. `CLAUDE.md` — current schema and skill list
2. `wiki/overview.md` — schema version note
3. `wiki/meta/taxonomy.md` — to know which tags are canonical
4. `wiki/log.md` — to date last activity
5. `.raw/.manifest.json` — to know ingest state

## What this skill DOES NOT fix

This skill is read-only — it produces a report, never modifies the vault. To actually fix the issues:
- For frontmatter gaps → manually edit pages or run the relevant template-fill workflow
- For `[!ai-writing]` callouts → `humanize batch --scope flagged-by-lint`
- For orphans → `cross-linker` then remove what still has 0 incoming
- For doc drift → manually edit the affected docs

## Cross-skill integration

- Strict superset of the most critical `wiki-lint` checks. Doesn't replace lint — runs orthogonally.
- Should be run AFTER `wiki-lint`, AFTER any `humanize batch`, and AFTER `cross-linker`.
- The CI workflow at `.github/workflows/lint.yml` runs a subset of these checks on every PR.
