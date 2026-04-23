---
name: wiki-query
description: Answer questions from the wiki using a token-disciplined retrieval ladder. Use when the user asks any question about wiki content. Three modes — index-only (fast, summary-only), standard (3-5 pages), deep (8000+ tokens, multi-page synthesis). Files good answers back to wiki/questions/.
---

# wiki-query

Answer questions from the wiki content. The wiki is your library — read it efficiently.

## The Retrieval Primitives Ladder

Token discipline is the whole game. **A 500-line page opened to read 15 lines is 485 lines of wasted tokens.** Climb this ladder; only escalate when the cheaper rung can't answer:

1. **Frontmatter-scoped grep** — `Grep` with `-A 0` for `type:`, `title:`, `tags:` matches across `wiki/**/*.md`. Cheapest. Answers "does this exist?" and "where might it be?"

2. **`summary:` field read** — for candidate pages, read ONLY the frontmatter `summary:` field. This is the load-bearing field — pages have it precisely so cheap retrieval works. Answers "what is this page about?"

3. **Sectioned grep on body** — `Grep -A N -B N` with N small (3-10) for specific terms. Answers "what does the page say about X?"

4. **Full `Read`** — only when the cheaper passes can't answer. Answers "tell me everything in this page."

**Default rule:** start at rung 1. Escalate only when needed. Never start at rung 4.

---

## Modes

### `index-only` (fast — labels itself)

Use for quick lookups, status checks, "do we have anything on X?", or when the user says "quick answer."

1. Read `wiki/index.md` and `wiki/hot.md`.
2. Frontmatter-grep for relevant pages.
3. Read ONLY the `summary:` fields of matches.
4. Synthesize a 1-3 sentence answer.
5. **Always label the answer**: "(index-only answer — page bodies not read; may miss nuance)"

Token budget: ~1000 tokens of vault content, no full page reads.

### `standard` (default)

Use for normal queries.

1. Read `wiki/hot.md` (recent context).
2. Read `wiki/index.md`.
3. Identify 3-5 relevant pages via frontmatter-grep + `summary:` reads.
4. For pages that look most relevant, do sectioned grep first; full read only when needed.
5. Synthesize the answer with citations to specific pages.
6. Always cite as `[[wikilinks]]`.

Token budget: ~3000 tokens of vault content, 1-3 full page reads max.

### `deep` (when explicitly requested or topic warrants)

Use for synthesis questions, "tell me everything about", research dives.

1. Read `wiki/hot.md`, `wiki/index.md`, `wiki/overview.md`, and any relevant `_index.md`.
2. Identify 8-15 relevant pages.
3. Read most of them (still using sectioned grep where it suffices).
4. Walk wikilinks one hop deeper if a page references something important you haven't read.
5. Synthesize with structured output (sections, comparison tables where useful).
6. Cite extensively.

Token budget: ~8000+ tokens of vault content, multiple full reads.

### When to escalate vs. stay

- If `index-only` gives an answer that names ≥3 specific pages with detail beyond their summaries: stay.
- If `index-only` says "the wiki has pages on X but I haven't read their bodies": escalate to `standard`.
- If `standard` can't reconcile contradictions or the question is fundamentally synthesis-heavy: escalate to `deep`.

---

## File-back pattern

After answering, evaluate whether the answer is worth filing:

**File back when:**
- The answer required reading 3+ pages.
- The answer would be useful to someone else (or future-you) who asked the same question.
- The answer surfaced new gaps or open questions.
- The user explicitly says `file this answer` or `save this`.

**Don't file back when:**
- The answer is a single-line factual lookup (`when was X created?`).
- The answer is conversational or specific to right-now context.

To file back:

1. Use the `_templates/question.md` template.
2. Set `question:` to the user's verbatim wording.
3. Set `answer_quality:` based on confidence.
4. Save to `wiki/questions/<slugified-question>.md`.
5. Cross-link: add `[[wiki/questions/...]]` to the `related:` of every page you cited.
6. Append to `wiki/log.md` as a `query | <question>` entry.
7. Run `cross-linker` on the new question page.

---

## Citation discipline

- Always cite specific wiki pages, never "training data" or "common knowledge."
- Cite as `[[wikilinks]]`, not URLs (unless citing the original source).
- If you can't find an answer in the wiki, SAY SO. Don't fabricate from training data.
- If you can answer partially from the wiki and partially from training, label which is which.

---

## Provenance-aware answering

When citing wiki content, respect the markers:

- Claims without markers (EXTRACTED) — present as fact.
- `^[inferred]` claims — present with hedge ("the wiki suggests..." or "per inference on `[[Page]]`")
- `^[ambiguous]` claims — present both sides ("the wiki notes contradictory accounts on this — see [[Page]]")

Pages with `confidence: low` — flag the answer's confidence accordingly.

---

## What to do when the wiki has nothing

If frontmatter-grep returns no matches AND the user's question is in-domain for this wiki:

1. Say so explicitly: "The wiki has no pages on X."
2. Suggest concrete next steps:
   - "You could ingest a source on X by dropping a file into `.raw/`."
   - "Try `/autoresearch X` to populate the wiki autonomously."
   - "Drop a draft into `wiki/_raw/` and I'll promote it."

NEVER fabricate wiki content. NEVER claim a page exists when it doesn't.

---

## Writing-style discipline (for synthesized answers)

When you write a synthesis answer (especially in `standard` and `deep` modes), follow `skills/wiki/references/writing-style.md`. Before filing back to `wiki/questions/`, run the self-audit pass. Synthesis pages skew inferred and are the most AI-prone — extra discipline here matters most.

## Reading list before querying

1. `wiki/hot.md` (recent context — almost always relevant)
2. `wiki/index.md` (catalog)
3. Sub-indexes for the apparent domain
4. Then the retrieval ladder
5. `skills/wiki/references/writing-style.md` IF filing the answer back as a question page
