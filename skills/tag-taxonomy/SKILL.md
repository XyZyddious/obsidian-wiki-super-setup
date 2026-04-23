---
name: tag-taxonomy
description: Audit, normalize, and consult the canonical tag vocabulary in wiki/meta/taxonomy.md. Four modes — audit (report drift), normalize (apply fixes), consult (INTERACTIVE — uses AskUserQuestion to elicit decisions on new tag candidates during ingest, so the user never has to maintain taxonomy.md by hand), add (propose a new canonical tag). Use when user mentions tags, tagging, taxonomy, normalize tags, audit tags. Auto-invoked by wiki-ingest at Step 5a.
---

# tag-taxonomy

Single source of truth for tags is `wiki/meta/taxonomy.md`. This skill keeps the wiki aligned with it.

## Modes

### `audit` (default — read-only)

Walk every page in `wiki/`. For each page's `tags:`, check:

1. **Canonicality** — is each tag listed in `wiki/meta/taxonomy.md`?
2. **Aliases** — is the page using a non-canonical alias (e.g. `ml` instead of `machine-learning`)?
3. **Visibility tags** — exempt from 5-cap; verify they're spelled correctly (`visibility/public`, `visibility/internal`, `visibility/pii` only).
4. **Tag count** — ≤ 5 content tags (excluding `visibility/*`).
5. **Reserved prefix misuse** — pages using `type/`, `domain/`, `status/`, `visibility/`, `project/` prefixes for non-canonical tags.

Report:

```
Tag Taxonomy Audit — 2026-04-23

Total pages: 312
Total unique tags: 47
Canonical tags in taxonomy.md: 42
Non-canonical tags appearing on pages: 5
  - "crypto" (12 pages) — alias of "cryptography"
  - "infra" (4 pages) — alias of "infrastructure"
  - "wiki-stuff" (3 pages) — undefined; suggest add or remove

Pages exceeding 5-tag limit: 3
  - wiki/concepts/Big Concept.md (7 tags)
  - ...

Tag count drift (tags with <3 pages):
  - "obscure-thing" (1 page) — consider removing
  - ...

Reserved prefix misuse: 0

Recommendation: Run `tag-taxonomy normalize` to fix 16 alias usages.
```

### `normalize` (apply fixes)

Apply the audit findings:

1. For each non-canonical alias on a page, REPLACE with canonical form.
2. For pages exceeding 5-tag limit, FLAG (don't auto-remove — ambiguous which to drop).
3. For reserved prefix misuse, FLAG (don't auto-fix — could be intentional or wrong).
4. Update each modified page's `updated:` frontmatter field.
5. Append a single combined `wiki/log.md` entry.

Never invent tags. Only normalize against existing canonical entries in `wiki/meta/taxonomy.md`.

### `consult` (advise on a new page — INTERACTIVE)

When `wiki-ingest` calls this mode (or the user invokes it directly), it returns a finalized tag list AFTER eliciting decisions from the user about any new candidates.

**The user does NOT want to maintain `taxonomy.md` by hand.** This mode is the entry point for all new tag adoption. Every new candidate gets surfaced via `AskUserQuestion` before being written to `taxonomy.md`.

Input: page content + draft candidate tags (typically extracted by `wiki-ingest` from titles, headings, repeated noun phrases)
Output: finalized tag list (≤5 content + visibility) + side effect: `taxonomy.md` updated for any "Adopt" decisions

#### Process

1. **Classify each candidate** against `wiki/meta/taxonomy.md`:
   - **Canonical hit** — already in taxonomy → use directly
   - **Alias hit** — matches an entry in the Aliases section → auto-normalize to canonical
   - **Near-match** — similar to an existing canonical (Levenshtein < 3, or shared root) → flag as alias candidate
   - **New** — no match → flag for elicitation

2. **PII auto-suggest**: scan page body for PII patterns (`password`, `api_key`, `secret`, `token`, `email:` followed by value). If found, auto-add `visibility/pii` to the tag set with a note. Also suggest `visibility/internal` if the body mentions confidentiality, NDA, or work-internal markers.

3. **Batch-collect new candidates**. Don't ask one by one — collect ALL new candidates from this consult call.

4. **Elicit via `AskUserQuestion`**. One question per new candidate. Up to 4 questions per call (paginate if more candidates).

   **Question template:**

   ```yaml
   question: "I noticed `<candidate-tag>` (mentioned <N>x). How should I handle it?"
   header: "<candidate-tag>"      # max 12 chars; truncate if needed
   multiSelect: false
   options:
     - label: "Adopt as canonical"
       description: "Add to wiki/meta/taxonomy.md as a new canonical tag in the <inferred-section> section. Use it on this page and future pages."
     - label: "Map to <closest-canonical>"
       description: "Treat <candidate-tag> as an alias of <closest-canonical>. Add to Aliases section. Use <closest-canonical> on this page."
     - label: "Map to <second-closest>"
       description: "Treat <candidate-tag> as an alias of <second-closest>. (Only include if a real second match exists.)"
     - label: "Skip"
       description: "Don't tag pages with <candidate-tag>. Don't add to taxonomy.md. Don't ask again this ingest."
   ```

   **Recommendation rules:**
   - If the candidate is a near-match to an existing canonical (e.g. `ml` ↔ `machine-learning`) → make "Map to" the first option with `(Recommended)` suffix.
   - If the candidate appears on ≥3 pages in this ingest AND has no close canonical → make "Adopt as canonical" the first option with `(Recommended)` suffix.
   - For ambiguous candidates (1-2 mentions, no close match) → no recommendation; let user choose.

5. **Apply decisions:**
   - **Adopt as canonical** → call `tag-taxonomy add <tag> --section <type|domain|status|project>` (writes to `taxonomy.md`). Include the new tag in the page's tag list.
   - **Map to existing** → use the canonical tag instead of the candidate. Add the alias mapping to taxonomy.md's Aliases section if not already there.
   - **Skip** → omit the candidate; don't add anything to taxonomy.md.

6. **Enforce caps**: after applying decisions, ensure tag count ≤ 5 (excluding `visibility/*`). If over, prompt the user with one more `AskUserQuestion` to drop tags.

7. **Return** the finalized tag list with notes:

```
Finalized tags: [type/concept, domain/machine-learning, domain/search, "visibility/internal"]

Decisions applied:
  - "ml" auto-normalized to "domain/machine-learning" (existing alias)
  - "machine-learning" was already canonical — used directly
  - "search" → user chose ADOPT — added to taxonomy.md under domain/
  - "visibility/internal" auto-added — page mentions confidentiality
  - "stuff" → user chose SKIP — not added

Taxonomy.md updated:
  + domain/search (new canonical)
```

#### When NOT to ask

- If all candidates resolve canonically or via existing aliases → return silently, no `AskUserQuestion` call.
- If `wiki-ingest` is in `full` mode (rebuild from `.raw/`) and the same candidates were already decided in this run → reuse prior decisions, don't re-ask.
- If the user has previously set a session-level "auto-skip new tags" flag → honor it, log skipped candidates, don't ask.

#### When to escalate to `add` mode

If the user picks "Adopt as canonical" but the new tag would conflict with an existing canonical or alias, hand off to `add` mode to resolve (it will surface the conflict and ask for a renamed tag).

### `add` (propose a new canonical tag)

When a user wants to add a new canonical tag:

1. Validate the tag name (kebab-case; under reserved prefix if applicable).
2. Check it doesn't conflict with existing tags or aliases.
3. Add an entry to `wiki/meta/taxonomy.md` under the appropriate section.
4. If the new tag is meant to absorb existing usages (i.e. it's a canonical for an existing alias), update the Aliases section.
5. Suggest running `tag-taxonomy normalize` to apply.

---

## Reading list before any mode

1. `wiki/meta/taxonomy.md` — the source of truth
2. The page or page set you're operating on

## Cross-skill integration

- `wiki-ingest` calls `tag-taxonomy consult` when writing new pages.
- `wiki-lint` calls `tag-taxonomy audit` as part of Check 11 (fragmented tag clusters).
- `cross-linker` uses canonical tags for the "shared tags" scoring rule.
- `wiki-export` uses `visibility/*` tags to gate output.

## What never to do

- Never auto-create a new canonical tag without explicit user approval.
- Never auto-remove tags from a page (audit + flag, don't delete).
- Never normalize a `visibility/*` tag to anything else.
- Never write to `wiki/meta/taxonomy.md` outside `add` mode.
