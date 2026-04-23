---
description: Rewrite synthesis prose to remove AI-writing tells (significance inflation, AI vocabulary, em-dash overuse, "not just X but Y", inline-bolded lists, filler, etc.) per skills/wiki/references/writing-style.md. Preserves frontmatter, wikilinks, provenance markers, callouts, code blocks. Skips source pages.
---

Read the `humanize` skill (`skills/humanize/SKILL.md`). Then run the rewrite operation.

## Usage

- `/humanize <page>` — rewrite a single page in place
- `/humanize batch --pattern <pattern>` — fix one named pattern across many pages
- `/humanize batch --pattern <pattern> --scope <scope>` — restrict scope (`all`, folder, `tag:<tag>`, `flagged-by-lint`)
- `/humanize calibrate` — interactive: paste 2-3 paragraphs of your writing for voice matching
- `/humanize calibrate --auto` — auto-sample voice from existing user-authored pages
- `/humanize calibrate --from <source>` — sample from a specific page or folder

## Patterns supported (for batch mode)

`vocabulary, copula, em-dash, negative-parallel, inline-bold-list, title-case-headings, filler, hedging, wrap-up-conclusions, sycophantic, significance-inflation, vague-attributions`

## Behavior

1. Read `skills/wiki/references/writing-style.md` and (if present) `wiki/meta/voice-sample.md`.
2. For single-page mode: skip if page is `type: source` or `provenance.extracted >= 0.9` (extracted content shouldn't be rewritten).
3. Preserve frontmatter, all `[[wikilinks]]`, inline provenance markers, callouts, code blocks. Only touch prose.
4. Show diff summary before saving: "12 changes (3 vocabulary, 4 copula, ...)".
5. Bump `updated:` field; recompute `provenance.inferred` if rewrites were substantive.
6. Run `cross-linker` scoped to touched pages (rewrites can move wikilink-eligible text).
7. Append to `wiki/log.md`.
