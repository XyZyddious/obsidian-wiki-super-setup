---
description: Open, create, or update an Obsidian visual canvas. Add images, text cards, PDFs, wiki pages, and AI-generated assets to .canvas files in wiki/canvases/.
---

Read the `canvas` skill (`skills/canvas/SKILL.md`). Then run the operation matching the user's command.

## Operations

| Command | What it does |
|---|---|
| `/canvas` | Status check — report node counts, list zones, open instructions |
| `/canvas new [name]` | Create a new named canvas in `wiki/canvases/` |
| `/canvas add image [path]` | Add image to canvas (download if URL, copy if outside vault) |
| `/canvas add text [content]` | Add a text card to the canvas |
| `/canvas add pdf [path]` | Add a PDF document node |
| `/canvas add note [page]` | Add a wiki page as a linked card |
| `/canvas zone [name] [color]` | Add a new labeled zone group |
| `/canvas list` | List all canvases with node counts |
| `/canvas from banana` | Find recent generated images and add them |

Default canvas: `wiki/canvases/main.canvas`

## Behavior

- If `wiki/canvases/` doesn't exist, create it.
- If the canvas file doesn't exist, create it before adding anything.
- Always read the canvas file before writing — parse existing nodes to avoid ID collisions and calculate auto-positions.
- Update `wiki/index.md` when creating new canvases.
- Canvas nodes don't carry the universal frontmatter (canvas files are JSON, not Markdown), but any wiki pages embedded as nodes do.
