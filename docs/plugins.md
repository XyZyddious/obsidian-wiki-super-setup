# Obsidian Plugin Recommendations

The vault works without any community plugins. The recommendations below add features that meaningfully improve the experience.

---

## Required (or strongly enhance the vault)

| Plugin | Why | Author | URL |
|---|---|---|---|
| **Dataview** | Renders the queries in `wiki/meta/dashboard.md`. Without it, those query blocks appear as code. | blacksmithgu | https://github.com/blacksmithgu/obsidian-dataview |
| **Obsidian Bases** | Bases is built into Obsidian since 2025 — no install needed. The `wiki/meta/dashboard.base` file uses it for native, fast database views over the wiki. | Obsidian (built-in) | (Settings → Core plugins) |

If you don't install Dataview, just use `dashboard.base` — it's plugin-free.

---

## Strongly recommended

| Plugin | Why | Author | URL |
|---|---|---|---|
| **Templater** | Auto-fills frontmatter when creating new pages from `_templates/`. Without it, you'd manually paste the template each time. | SilentVoid13 | https://github.com/SilentVoid13/Templater |
| **Obsidian Git** | Auto-commits, push/pull, conflict resolution from inside Obsidian. Pairs well with the `PostToolUse` hook that auto-commits wiki changes. | denolehov | https://github.com/denolehov/obsidian-git |
| **Calendar** | Sidebar calendar with daily-note jump and word counts. Useful for journal-heavy workflows. | liamcain | https://github.com/liamcain/obsidian-calendar-plugin |

---

## Nice-to-have

| Plugin | Why | Author | URL |
|---|---|---|---|
| **Banners** | Add `banner: <image-path>` to any page's frontmatter for a header image. Pairs with the optional `banner_icon: 🧠` for emoji headers. | noatpad | https://github.com/noatpad/obsidian-banners |
| **Excalidraw** | Freehand drawing and image annotation, embeddable in pages. The setup script downloads `main.js` automatically. | zsviczian | https://github.com/zsviczian/obsidian-excalidraw-plugin |
| **Thino** | Quick memo capture into a sidebar — fast intake before promotion to `wiki/_raw/`. | Quorafind | https://github.com/Quorafind/Obsidian-Thino |
| **Style Settings** | Tweak the appearance of any CSS snippet (the vault ships with `vault-colors.css` for folder color-coding). | mgmeyers | https://github.com/mgmeyers/obsidian-style-settings |

---

## Optional, situational

| Plugin | Use when |
|---|---|
| **MetaEdit** | You want to edit frontmatter through a UI instead of YAML directly. |
| **Tag Wrangler** | You're cleaning up legacy tags (less important here since `tag-taxonomy` enforces canonical vocab). |
| **Folder Note** | You want `_index.md` to show as a "folder note" when you click the folder. |
| **Iconize** | You want icons in the file explorer next to folders. |
| **Periodic Notes** | Daily/weekly/monthly note workflows. The vault's `journal/` works without it. |

---

## Avoid (or be cautious)

| Plugin | Why |
|---|---|
| **Smart Connections** / **Copilot** / other AI plugins | They duplicate what the wiki skills do, but without provenance discipline, content-trust boundary, or the universal frontmatter. They'll create pages that fail `wiki-lint`. If you use them, scope them to drafting only — never let them write directly to `wiki/`. |
| **Plugins that auto-modify files in bulk** | The `PostToolUse` auto-commit hook will capture every change as a commit. Plugins that touch many files at once will create commit noise. Configure them to a separate folder or disable auto-actions. |

---

## Setup checklist

After installing the vault:

1. Run `bash bin/setup-vault.sh` — enables the bundled CSS snippets and downloads Excalidraw's main.js if missing.
2. Open Obsidian → Manage Vaults → Open folder as vault → select this directory.
3. **Settings → Community Plugins → Browse** to install the recommended set.
4. Enable Bases (Settings → Core Plugins → Bases) if not already on.
5. Optional: enable Obsidian Git's auto-pull on startup, auto-commit on interval (e.g., 10 min), and auto-push.

## Hot tip

The CSS snippet `vault-colors.css` (bundled in `.obsidian/snippets/`) color-codes the wiki folders in the file explorer. Enable via Settings → Appearance → CSS snippets. Without it the folders are all uniform gray.
