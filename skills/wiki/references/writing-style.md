# Writing Style Guide

The single source of truth for prose conventions in this vault. Every skill that generates prose (`wiki-ingest`, `wiki-query`, `save`, `autoresearch`, `wiki-status`, `wiki-lint`, `wiki-rebuild` reports) must read this before writing and self-audit after.

Synthesized from the [Wikipedia Signs of AI Writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) catalog plus our own carve-outs for wiki context. The goal: prose that earns trust because it sounds like a thoughtful person took the time to write it — not a model padding statistical templates.

---

## The core principle

**Write the knowledge, not a performance of knowledge.** A wiki page exists to make a future reader smarter, faster. Every word should carry information. Every adjective should be load-bearing. Every sentence should advance understanding. If a sentence could be deleted without information loss, delete it.

---

## What we DO want (wiki-context positives)

These are intentional and good — the AI-detection catalog flags some of them in Wikipedia context, but they belong here:

- **Inline provenance markers**: `^[inferred]` and `^[ambiguous]` are functional, not decorative. Use them honestly.
- **Wikilinks**: `[[Page Name]]` for any reference to another wiki page. Density is fine.
- **Custom callouts**: `[!contradiction]`, `[!gap]`, `[!key-insight]`, `[!stale]`. Use when they earn their place.
- **Type-specific structured fields** in frontmatter: `key_claims`, `verdict`, `decisions_made` etc. Lists are correct here.
- **Code blocks** for data, paths, commands. Don't paraphrase technical content into prose.
- **Concise tables** for genuine comparisons or reference matter. Not for things prose handles fine.

---

## Content patterns to avoid

### 1. Significance inflation

Don't manufacture importance. Don't write "marks a pivotal moment" or "represents a transformative shift" or "stands as a testament to" unless the source actually argues that and you can cite it.

| ❌ AI tell | ✅ Better |
|---|---|
| "The framework marks a pivotal moment in retrieval research." | "Karpathy proposed the framework in 2024." |
| "This represents a fundamental shift in how vaults are organized." | "The vault uses three layers instead of two." |
| "The system stands as a testament to compounding knowledge." | "The system compounds — each ingest tightens cross-references." |

### 2. Notability name-dropping

Don't list outlets/sources as proof of importance. Cite what they said.

| ❌ AI tell | ✅ Better |
|---|---|
| "Featured in CNN, Vogue, and Wired." | "CNN noted the API rate limits; Wired highlighted the privacy filter." |
| "Has independent coverage across multiple media outlets." | "[[CNN article on X]] is the best summary." |

### 3. Superficial -ing analyses

Drop participles that pretend to add insight without doing so.

| ❌ AI tell | ✅ Better |
|---|---|
| "...creating a vibrant community." | (delete or replace with what specifically the community does) |
| "...highlighting the importance of provenance." | "Provenance lets `wiki-lint` flag drift." |
| "...facilitating cross-references across pages." | "Cross-linker inserts `[[wikilinks]]`." |

### 4. Promotional / press-release tone

| ❌ AI tell | ✅ Better |
|---|---|
| "boasts a vibrant ecosystem of plugins" | "ships with 6 utility skills" |
| "nestled in the heart of the vault" | "lives at `wiki/meta/`" |
| "thoughtfully designed", "groundbreaking", "diverse array" | (delete the adjective; state the fact) |

### 5. Vague attributions / weasel words

Cite specific sources or don't claim it.

| ❌ AI tell | ✅ Better |
|---|---|
| "Researchers have observed..." | "[[Smith 2024]] reports..." |
| "Industry experts argue..." | (delete unless you can name them) |
| "Some sources suggest..." | "[[Source]] suggests..." |

### 6. Formulaic "challenges" sections

Skip the "Despite challenges, X continues to thrive" structure. State problems directly.

---

## Language patterns to avoid

### 7. AI vocabulary

These words appear far more often in post-2022 text than before. Use only when no plainer word fits, and prefer the right side:

| ❌ AI tell | ✅ Better |
|---|---|
| delve into | look at, examine, study |
| tapestry, landscape | (skip — usually empty metaphor) |
| pivotal, crucial | important, key (but ask: is it really?) |
| vibrant, rich, diverse | (skip — usually empty) |
| meticulous, intricate | careful, complex |
| boasts, features, showcases | has, includes, shows |
| testament to | (skip entirely) |
| garner, foster, cultivate, bolster | get, build, support |
| underscore, emphasize, highlight | show, point out (or cut) |
| align with, resonate with | match, fit |
| navigate the complexities of | work through, handle |
| in the realm of | in (drop the phrase) |
| at its core | (skip) |
| unlock | enable, allow |
| empower | let, help |
| seamless | (skip — almost always padding) |

### 8. Copula avoidance

Use plain `is` and `are`. Don't replace them with longer constructions.

| ❌ AI tell | ✅ Better |
|---|---|
| "Cross-linker serves as a scoring engine." | "Cross-linker is a scoring engine." |
| "Hot.md represents the session bridge." | "Hot.md is the session bridge." |
| "The manifest stands as the source of truth." | "The manifest is the source of truth." |
| "X marks the boundary between Y and Z." | "X separates Y from Z." |

### 9. Negative parallelisms

The "Not just X, but Y" structure is overused.

| ❌ AI tell | ✅ Better |
|---|---|
| "Not just a wiki, but a compounding knowledge base." | "A compounding knowledge base." |
| "Not merely cross-references, but contradictions surfaced." | "Cross-references AND surfaced contradictions." |

### 10. Rule of three

Triadic lists ("A, B, and C") feel rhythmic but become a tic. Vary your sentence shapes.

| ❌ AI tell | ✅ Better |
|---|---|
| "Concise, accurate, and well-sourced." | "Concise and well-sourced." (or 4, or 2) |
| "Ingest, query, and lint." | (use only when there really are three) |

### 11. Elegant variation

Reusing the same noun is fine. Don't cycle through synonyms to avoid repetition.

| ❌ AI tell | ✅ Better |
|---|---|
| "The wiki stores facts. The compendium tracks sources. The repository links them." | "The wiki stores facts, tracks sources, and links them." |
| "the protagonist... the key player... the eponymous character" | (pick one and stick with it) |

### 12. False ranges / hedge stacking

| ❌ AI tell | ✅ Better |
|---|---|
| "5-15 pages per source" | "8-12 pages per source" (give a real range, not a wide hedge) |
| "It's worth noting that, generally speaking, this can sometimes..." | "Sometimes this..." |

---

## Style and formatting patterns to avoid

### 13. Em-dash overuse

Em dashes are fine. Em-dash density above ~1 per paragraph is a tell. Mix with commas, parentheses, and colons.

### 14. Boldface tics

Don't bold every instance of a key term. Don't bold for emphasis when context already emphasizes. Use bold for the FIRST definition of a term in a section, not throughout.

### 15. Inline-header bolded lists

Avoid lists where every item is `**Term:** description`. Either use a proper definition list, prose, or shorter bullets.

### 16. Title Case headings inside body

Use sentence case (`## What this means`), not title case (`## What This Means`).

### 17. Curly quotes / typographer apostrophes

Use straight `"..."` and `'`. (This is the Wikipedia convention; matters less in Obsidian. Be consistent.)

### 18. Tables for things that aren't comparisons

If two short paragraphs would work, write two short paragraphs. Tables are for structured comparison.

### 19. Skipping heading levels

Don't jump from `##` to `####`. Use `###` for the level in between.

### 20. Thematic breaks before headings

Don't put `---` before every heading. Use sparingly.

---

## Communication / markup patterns to avoid

### 21. Collaborative-tone phrases

A wiki page isn't an email. Drop:
- "I hope this helps"
- "Let me know if you'd like me to expand on..."
- "I appreciate any feedback"
- "Open to suggestions"

### 22. Knowledge-cutoff disclaimers

A wiki page should NOT say "as of my knowledge cutoff" or "this may not reflect current state." If the info might be stale, mark the page `status: developing` or add `[!stale]`.

### 23. Sycophantic openers

For chat replies (not page bodies), drop:
- "Great question!"
- "That's a really insightful point."
- "Excellent observation!"

### 24. LLM markup leakage

Strip `<contentReference>`, `<oaicite>`, `<oai_citation>`, `<grok_card>`, etc. before saving any page.

---

## Filler and hedging patterns to avoid

### 25. Filler phrases

| ❌ AI tell | ✅ Better |
|---|---|
| "In order to" | "To" |
| "Due to the fact that" | "Because" |
| "It's worth noting that" | (delete) |
| "It is important to remember" | (delete) |
| "At the end of the day" | (delete) |
| "Needless to say" | (delete) |
| "In essence" | (delete or just say it) |
| "Ultimately" | (often deletable) |
| "Furthermore" / "Moreover" | (often deletable) |

### 26. Excessive hedging

| ❌ AI tell | ✅ Better |
|---|---|
| "It could potentially be argued that perhaps..." | "Perhaps..." (and ideally just say it) |
| "This may possibly suggest..." | "This suggests..." (or "we don't know") |
| "tends to often be" | "is often" |

### 27. Generic conclusions

Don't end with a wrap-up paragraph that restates the page. Stop when you're done.

| ❌ AI tell | ✅ Better |
|---|---|
| "In conclusion, the wiki super setup represents a comprehensive approach to..." | (delete the whole paragraph; the page already said it) |
| "Overall, this skill provides users with..." | (delete) |

---

## Self-audit checklist

After writing prose, do a 30-second audit pass. Skim for:

- [ ] Any AI vocabulary words (delve, tapestry, vibrant, boasts, etc.)?
- [ ] Em-dash density above ~1 per paragraph?
- [ ] Sentences using "serves as", "stands as", "marks", "represents" where "is" would do?
- [ ] "Not just X, but Y" structures?
- [ ] Title Case in headings inside body?
- [ ] `**Term:** description` lists?
- [ ] Filler phrases ("in order to", "it's worth noting that")?
- [ ] A wrap-up "In conclusion" paragraph?
- [ ] Sycophantic or collaborative-tone phrases?
- [ ] Generic adjectives (vibrant, rich, profound, meticulous) without specifics?
- [ ] Three-item lists when two or four would also be fine?
- [ ] Synonym cycling for the same concept?
- [ ] Vague attributions ("researchers", "experts", "observers")?

If any of these are present and not load-bearing, rewrite or cut.

---

## When to invoke `humanize`

Don't write prose, then run humanize as a fix. Humanize is for:

- Rewriting an existing page that predates this guide
- Batch-fixing a single pattern across many pages (e.g., "remove em-dash overuse from all `wiki/concepts/`")
- A final pass before publishing the vault to GitHub or sharing externally
- Pages flagged by `wiki-lint` Check 13

The expected steady state is: prose written following this guide, occasional `humanize` runs to catch drift.

---

## Voice calibration (optional)

If you want generated prose to match your own writing style, drop 2-3 paragraphs of your own writing into `wiki/meta/voice-sample.md`. The `humanize` skill reads it and matches sentence rhythm, vocabulary preferences, and structural habits. Without it, humanize defaults to "plain, direct, factual."

---

## A note on what NOT to over-correct

This guide is about removing tells, not flattening prose. A page that follows every rule mechanically will read as flat and bureaucratic. Some traits to KEEP:

- Sentence variety — short and long sentences mixed
- Real metaphors when they earn the line (not "tapestry of features")
- Em dashes in moderation
- Strong opinions when sourced
- Specific numbers, names, and dates
- The author's actual point of view

The goal is prose someone would want to re-read because it taught them something — not prose that passes a checker.
