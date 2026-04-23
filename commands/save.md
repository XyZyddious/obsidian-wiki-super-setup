---
description: Save the current conversation or a specific insight into the wiki vault as a structured note with universal frontmatter (summary, provenance, confidence) and run cross-linker.
---

Read the `save` skill (`skills/save/SKILL.md`). Then run the save workflow for this conversation.

## Usage

- `/save` — analyze the full conversation and save the most valuable content
- `/save [name]` — save with a specific note title (skip the naming question)
- `/save question [name]` — explicitly save as a question/answer page
- `/save concept [name]` — explicitly save as a concept page
- `/save decision [name]` — explicitly save as a decision record
- `/save journal` — save as a time-stamped journal entry

## Behavior

1. If no vault is set up yet, say: "No wiki vault found. Run `/wiki` first to set one up."
2. Check if a page with the same name already exists. If yes, offer to UPDATE instead of CREATE.
3. Pick the right template from `_templates/` based on content type.
4. Build full universal frontmatter: `summary`, `provenance`, `confidence` are REQUIRED.
5. Run `tag-taxonomy consult` before tagging — it will pause to ask via `AskUserQuestion` about any new tag candidates (the user does NOT maintain `taxonomy.md` by hand).
6. Apply inline `^[inferred]` and `^[ambiguous]` markers honestly — saved answers are often more synthesis than extraction.
7. Run `cross-linker` scoped to the new page after saving.
8. Update `wiki/index.md`, append to `wiki/log.md`, refresh `wiki/hot.md`.
