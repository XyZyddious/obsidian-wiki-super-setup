---
name: save
description: File the current conversation, answer, or insight as a structured wiki page using the universal frontmatter (summary, provenance, confidence). Picks the right template (question/concept/decision/journal/comparison), creates frontmatter with provenance markers in the body, files in the correct wiki folder, runs cross-linker on the new page, and updates index, log, and hot cache. Triggers on "save this", "/save", "file this", "save to wiki", "save this conversation", "keep this", "add this to the wiki".
---

# save: File Conversations Into the Wiki

Good answers and insights shouldn't disappear into chat history. This skill takes what was just discussed and files it as a permanent wiki page following the universal frontmatter discipline.

The wiki compounds. Save often.

---

## Note type decision

Pick the template based on conversation content:

| Template | Folder | Use when |
|---|---|---|
| `question` | `wiki/questions/` | Multi-step analysis or answer to a specific question |
| `concept` | `wiki/concepts/` | Explaining or defining an idea, pattern, or framework |
| `comparison` | `wiki/comparisons/` | Side-by-side analysis of multiple things |
| `decision` | `wiki/journal/` (or `wiki/projects/<name>/decisions/`) | A choice made with rationale |
| `meeting` / `journal` | `wiki/journal/` | Time-stamped session or meeting notes |
| `source` | `wiki/sources/` | Summary of external material discussed |

If the user specifies a type, use that. Otherwise pick the best fit. When in doubt, use `question`.

---

## Save workflow

1. **Scan** the current conversation. Identify the most valuable content to preserve.
2. **Determine** template using the table above.
3. **Title** — if not provided, propose one in 3-7 words and ask if it's OK.
4. **Check for existing page** — GREP titles + aliases. If a similar page exists, offer UPDATE instead of CREATE.
5. **Extract** content. Rewrite in declarative present tense (NOT "the user asked", but the actual knowledge).
6. **Build frontmatter** using the universal spec (see `skills/wiki/references/frontmatter.md`):
   - `type`, `title`, `created`, `updated`, `status: developing`
   - `tags`: consult `wiki/meta/taxonomy.md`. New candidates → use `tag-taxonomy consult` (which will pause to ask via `AskUserQuestion` if any are non-canonical).
   - `summary:` — 1-2 sentences, ≤200 chars
   - `provenance:` — rough fractions. If the answer was your synthesis across multiple wiki pages, default to roughly `extracted: 0.4, inferred: 0.55, ambiguous: 0.05`. If extracted from a single recent source, more like `0.85 / 0.13 / 0.02`.
   - `confidence:` — `high` / `medium` / `low` based on source count and ambiguity
   - Type-specific fields (e.g. `question:`, `decision_status:`)
7. **Apply inline provenance markers** in the body — no marker (EXTRACTED), `^[inferred]`, `^[ambiguous]`.
8. **Add `sources:`** for any wiki pages you cited.
9. **Add `related:`** for any other relevant wiki pages.
10. **Visibility tag** — if the conversation touched on PII or internal/confidential context, add `visibility/internal` or `visibility/pii`.
11. **Cross-link pass** — invoke `cross-linker` scoped to the new page to insert wikilinks where the body mentions other registered pages.
12. **Update `wiki/index.md`** — add the new entry under the appropriate section.
13. **Append to `wiki/log.md`** at the top:

    ```
    ## [YYYY-MM-DD HH:MM] save | <Note Title>
    - type: <type>
    - location: wiki/<folder>/<Note Title>.md
    - from: conversation on <brief topic>
    - cross-linker: N links inserted
    ```

14. **Update `wiki/hot.md`** to reflect the new addition (1-2 sentence note in the auto-refresh section).
15. **Confirm** to user: "Saved as `[[<Note Title>]]` in `wiki/<folder>/`. Cross-linker inserted N links."

---

## Frontmatter example (question type)

```yaml
---
type: question
title: "How does the retrieval-primitives ladder work?"
created: 2026-04-23
updated: 2026-04-23
tags: [question, type/question, domain/wiki-architecture]
status: developing
summary: >-
  The 4-tier ladder climbs frontmatter grep → summary read → sectioned grep → full read.
  Cheaper rungs answer most queries; only escalate when needed.
provenance:
  extracted: 0.45
  inferred: 0.50
  ambiguous: 0.05
confidence: medium
related:
  - "[[wiki/concepts/Retrieval Primitives]]"
sources:
  - "[[wiki/sources/ar9av-obsidian-wiki]]"
question: "How does the retrieval-primitives ladder work?"
answer_quality: solid
asked_by: "user"
asked_at: 2026-04-23
---
```

---

## Writing style

- Declarative, present tense. Write the knowledge, not the conversation.
- Not: "The user asked about X and Claude explained..."
- Yes: "X works by doing Y. The key insight is Z."
- Include enough context that a future reader can read this page cold.
- Link every mentioned concept, entity, or wiki page with `[[wikilinks]]`.
- Apply `^[inferred]` and `^[ambiguous]` markers honestly — saved answers are often more synthesis than extraction.

---

## What to save vs. skip

**Save:**
- Non-obvious insights or synthesis
- Decisions with rationale
- Analyses that took significant effort
- Comparisons that are likely to be referenced again
- Research findings

**Skip:**
- Mechanical Q&A (lookup questions with obvious answers)
- Setup steps already documented
- Temporary debugging sessions with no lasting insight
- Anything already in the wiki — UPDATE the existing page instead

---

## Writing-style discipline

Saved conversations are synthesis-heavy by nature (you're rewriting chat into structured prose). Read `skills/wiki/references/writing-style.md` before writing the page body. After writing, run the self-audit pass.

## Reading list

1. `skills/wiki/references/frontmatter.md` — universal frontmatter spec
2. `skills/wiki/references/writing-style.md` — prose conventions
3. `wiki/meta/taxonomy.md` — canonical tags
4. `wiki/index.md` — to find existing pages before creating duplicates
