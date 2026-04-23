---
name: wiki-lint
description: 14-check health audit of the wiki. Use when the user says "lint the wiki", "check the wiki", "is the wiki healthy?", "find broken links", or every 10-15 ingests. Checks structure (orphans, dead links, frontmatter), quality (summary, provenance drift, tag cohesion, visibility/PII), and AI-writing tells (vocabulary, em-dash density, copula avoidance, etc. — flagged for `humanize`). Self-healing where safe; flags everything else for review. Writes report to wiki/meta/lint-report-YYYY-MM-DD.md.
---

# wiki-lint

Health audit + self-healing pass on the wiki. 14 checks. Auto-fixes the safe ones; flags everything else.

## The 14 checks (was 13 + schema-version-drift)

### Structural (the original agrici 8)

1. **Orphans** — pages with no incoming wikilinks.
   - Auto-fix where safe: invoke `cross-linker` to find candidate links; insert EXTRACTED-confidence ones.
   - Flag remainder for review.

2. **Dead links** — wikilinks pointing to non-existent pages.
   - Auto-fix: if a near-miss match exists (e.g. case difference, plural), repair the link.
   - Otherwise flag with: "create [[Page]]?" or "delete the link?"

3. **Stale claims** — `[!stale]` callouts older than 6 months without re-verification.
   - Flag for review with the source page that should re-verify.

4. **Missing pages** — wikilinks on the index that don't exist as files.
   - Auto-fix: if the page was renamed (lookup git history), repair. Otherwise flag.

5. **Missing cross-references** — page A mentions page B by exact title in body but doesn't `[[link]]` it.
   - Auto-fix: insert the wikilink (delegate to `cross-linker` for scoring).

6. **Frontmatter gaps** — page missing required field (`type`, `title`, `created`, `updated`, `tags`, `status`, `summary`, `provenance`, `confidence`).
   - Auto-fix where deterministic (set `created` to file mtime, `updated` to today).
   - Flag for content fields (`summary`, `provenance`).

7. **Empty sections** — H2/H3 with no content under them.
   - Flag — don't auto-delete (might be intentional placeholder).

8. **Stale index entries** — `wiki/index.md` references pages that no longer exist or whose section is wrong.
   - Auto-fix.

### Quality (new from ar9av synthesis)

9. **Missing `summary:` field** — page has no `summary:` OR summary is > 200 chars OR summary is just the page title.
   - Soft warning, no auto-fix (Claude shouldn't make up summaries).

10. **Provenance drift** — recompute extracted/inferred/ambiguous fractions from inline markers; compare to frontmatter `provenance:` block.
    - Drift > 0.20 → flag with "update frontmatter to <new fractions>"
    - AMBIGUOUS > 15% → flag as "speculation-heavy — re-source or rewrite"
    - INFERRED > 40% with no `sources:` → flag as "unsourced synthesis"
    - Hub pages (top 10 by incoming) with INFERRED > 20% → flag with priority

11. **Fragmented tag clusters** — for each tag with ≥5 pages, compute cohesion = `actual_links / (n × (n-1) / 2)`.
    - Cohesion < 0.15 → flag with: "tag `<name>` has N pages but they don't link to each other. Run `cross-linker` scoped to this tag."

12. **Visibility / PII consistency** — grep page bodies for PII patterns (`password`, `api_key`, `secret`, `token`, `email:` followed by value, SSN/credit-card patterns).
    - Pages matching that LACK `visibility/pii` or `visibility/internal` → flag urgently
    - Pages with `visibility/pii` that LACK `sources:` → flag (PII should always have provenance)

### AI-writing tells (1)

13. **AI-writing tells** — for pages with `provenance.inferred > 0.4` (synthesis-heavy, most likely to have AI prose), scan body prose for the highest-signal patterns from `skills/wiki/references/writing-style.md`:
    - **AI vocabulary**: count occurrences of `delve|tapestry|landscape|vibrant|rich|profound|meticulous|intricate|boasts|features|showcases|testament|garner|foster|cultivate|bolster|underscore|emphasize|highlight|align with|resonate|navigate the complexities|seamless|in the realm of|at its core|unlock|empower`. Flag pages with ≥4 such words.
    - **Em-dash density** above 1 per paragraph (count `—` and `--` per line, average per ~5-line block).
    - **Negative parallelisms**: regex `not\s+(just|merely|only)\s+\w+,\s*but` — flag any page with ≥2.
    - **Copula avoidance**: count occurrences of `serves as|stands as|marks (a|the)|represents (a|the)|embodies` — flag pages with ≥3.
    - **Title Case in body headings**: regex `^#{2,4}\s+[A-Z]\w+\s+[A-Z]\w+(\s+[A-Z]\w+)+$` outside frontmatter — flag any page with ≥2.
    - **Inline-header bolded lists**: regex `^[-*]\s*\*\*[^*:]+:\*\*` — flag any page with ≥3 in a row.
    - **Filler phrases**: count `in order to|due to the fact that|it's worth noting|it is important to note|needless to say|at the end of the day` — flag pages with ≥2.
    - **Generic wrap-up conclusions**: pages whose last `## ` section heading matches `Conclusion|In conclusion|Overall|Summary|Final Thoughts|Wrapping Up` — flag for review.
    - Insert `[!ai-writing]` callouts at flagged sections.
    - Suggest: "Run `humanize <page>` to fix" on the report.
    - **Do not auto-fix.** Humanizing is a separate skill (`skills/humanize/`) with its own discipline.

### Schema-version drift (1)

14. **Schema-version freshness** — compare `CLAUDE.md` last-modified time to the schema version note in `wiki/overview.md`.
    - Find the line `**Schema version:**` in `wiki/overview.md`. The version note may include a date qualifier (e.g. `1.0` or `2.0.0 (last bumped 2026-XX-XX)`). Parse the date if present; if absent, treat the version note's most recent file mtime as the reference.
    - If `CLAUDE.md` mtime is more than 7 days newer than the version-note date → flag as "schema may have evolved without bumping the version note in `wiki/overview.md`."
    - Suggest: review what changed in `CLAUDE.md` and either bump the version note (e.g. 2.0.0 → 2.1.0) or backdate the schema version to the older one if no real changes were made.
    - Severity: LOW (cosmetic but accumulates if ignored).

---

## Workflow

### Step 1: Read the contract & current state

- `CLAUDE.md`
- `wiki/meta/taxonomy.md`
- `wiki/index.md`
- File listing of `wiki/`

### Step 2: Run all 14 checks

For each check, gather findings: `{check_id, severity, page, detail, suggested_fix, auto_fix_applied: true|false}`.

Severity levels:
- **HIGH** — security (PII), broken structure (dead links, missing required fields)
- **MEDIUM** — quality issues (orphans, provenance drift, missing cross-refs)
- **LOW** — cosmetic (empty sections, tag cluster cohesion)

### Step 3: Apply auto-fixes (safe ones only)

Auto-fix only when:
- The fix is deterministic (e.g. setting `updated:` to today)
- The fix matches an existing pattern (e.g. wikilink case repair to existing page)
- No content needs to be invented

Track every auto-fix in the report.

### Step 4: Write report

Save to `wiki/meta/lint-report-YYYY-MM-DD.md`:

```markdown
---
type: meta
title: "Lint Report YYYY-MM-DD"
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [meta, lint-report]
status: developing
summary: >-
  Lint findings for YYYY-MM-DD: X HIGH, Y MEDIUM, Z LOW. N auto-fixes applied.
provenance: {extracted: 1.0, inferred: 0.0, ambiguous: 0.0}
confidence: high
---

# Lint Report YYYY-MM-DD

**Total pages**: N
**Auto-fixes applied**: M
**Findings requiring review**: K (X HIGH, Y MEDIUM, Z LOW)

## HIGH severity (review now)

### Visibility/PII flags (Check 12)
- `[[wiki/journal/2026-04-21-meeting.md]]` — contains `password:` pattern; missing `visibility/pii` tag
  - Suggested: add `visibility/pii` to tags

### Dead links (Check 2)
- ...

## MEDIUM severity

### Orphans (Check 1)
- `[[wiki/concepts/Reciprocal Rank Fusion.md]]` — 0 incoming links
  - Suggested: cross-linker found 3 candidates: [[Wiki Search]], [[Hybrid Search]], [[BM25]]

### Provenance drift (Check 10)
- ...

## LOW severity

### Empty sections (Check 7)
- ...

## Auto-fixes applied
- Repaired wikilink case on [[Wiki vs RAG]] (was [[wiki vs rag]]) in 3 pages
- Updated 12 stale index entries
- ...

## Recommended next actions
1. Review HIGH severity items immediately.
2. Run `cross-linker` to address orphan suggestions.
3. Schedule next lint in 10-15 ingests.
```

### Step 5: Update wiki/log.md

```markdown
## [YYYY-MM-DD HH:MM] lint | full audit
- pages_checked: N
- auto_fixes: M
- findings: K (X H / Y M / Z L)
- report: [[wiki/meta/lint-report-YYYY-MM-DD]]
```

---

## Self-healing philosophy (from rohitg00)

The lint operation should TEND TOWARD HEALTH ON ITS OWN. Where safe:

- Insert wikilinks where there's an unambiguous match (delegate to cross-linker for scoring).
- Repair broken cross-references where a near-miss target exists.
- Mark stale claims with `[!stale]` callout where staleness is detectable.
- Update frontmatter `updated:` field to file mtime where it lags.
- Update `wiki/index.md` page count and "last updated" automatically.

Where NOT safe (must ask):
- Deleting any page or content.
- Inventing missing `summary:` text.
- Resolving contradictions (which side wins?).
- Promoting pages from `misc/` to `projects/`.
- Re-tagging beyond canonical normalization.

---

## When to run

- After every batch of 10-15 ingests.
- Before any `wiki-rebuild` operation.
- Weekly as standard hygiene.
- After any large `cross-linker` run.
