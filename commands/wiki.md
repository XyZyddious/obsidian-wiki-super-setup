---
description: Bootstrap or check the obsidian-wiki super setup. Reads the wiki orchestrator skill and routes to the right sub-skill.
---

Read the `wiki` skill (`skills/wiki/SKILL.md`). Then run the appropriate workflow.

## Setup check (no other args)

1. Verify Obsidian is installed (see `bin/setup-vault.sh` if needed).
2. Verify this directory is a vault — look for `wiki/` and `.obsidian/`.
3. Verify the super-setup files exist:
   - `wiki/index.md`, `wiki/hot.md`, `wiki/log.md`, `wiki/overview.md`
   - `wiki/meta/taxonomy.md`, `wiki/meta/dashboard.md`, `wiki/meta/insights.md`
   - `_templates/` with all 8 templates (source/entity/concept/comparison/question/project/decision/meeting)
   - `.raw/.manifest.json`
   - All 14 wiki skills in `skills/`: wiki, wiki-ingest, wiki-query, wiki-lint, wiki-status, cross-linker, tag-taxonomy, wiki-rebuild, wiki-export, humanize, wiki-publish-check, wiki-daily, wiki-search, wiki-migrate
4. Report current state — page counts, sources ingested, last lint, last insights run.

If anything is missing, scaffold it from the templates (don't ask).

If everything is in place AND the vault is empty (0 sources), suggest: "Drop a source into `.raw/` and say `ingest <filename>`."

If everything is in place AND the vault has content, suggest:
- `wiki status` to see what's pending
- Continue any threads visible in `wiki/hot.md`

## Routing (when args are given)

Match the user's intent to the right sub-skill:

| User says | Skill |
|---|---|
| "ingest [file/url/all]" | `wiki-ingest` |
| any question about wiki content | `wiki-query` |
| "lint" / "health check" | `wiki-lint` |
| "wiki status" / "what's pending" | `wiki-status` (delta mode) |
| "wiki insights" / "show hubs" / "graph health" | `wiki-status` (insights mode) |
| "cross-link" / "tighten" | `cross-linker` |
| "audit tags" / "normalize tags" | `tag-taxonomy` |
| "rebuild" / "archive" / "restore <ts>" | `wiki-rebuild` |
| "export" / "graph viz" | `wiki-export` |

## Notes

- The user does NOT maintain `wiki/meta/taxonomy.md` by hand. `wiki-ingest` pauses at Step 5a to elicit decisions on new tag candidates via `AskUserQuestion`.
- After every ingest, `cross-linker` runs automatically on touched pages.
- Read `CLAUDE.md` for the contract; `WIKI.md` for the deep schema reference.
