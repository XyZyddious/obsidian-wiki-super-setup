# Attribution

This vault is a synthesis of four LLM-Wiki implementations. Every file in `wiki/`, `_templates/`, `skills/wiki*`, `skills/cross-linker/`, `skills/tag-taxonomy/`, the new `CLAUDE.md`, `WIKI.md`, and `README.md` is an original synthesis. Several inherited components are credited below.

---

## The four source patterns synthesized

### LLM Wiki Pattern
- **Author:** Andrej Karpathy
- **Source:** https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
- **Used for:** Three-layer model (sources / wiki / schema), `index.md`, `log.md`, "compounding artifact" framing, the librarian role.

### LLM Wiki v2 (production patterns)
- **Author:** rohitg00
- **Source:** https://gist.github.com/rohitg00/2067ab416f7bbe447c1977edaaa681e2
- **Used for:** Confidence scoring, supersession workflow, decay (light implementation), self-healing lint, audit trail discipline, content-trust framing.

### claude-obsidian (parent fork)
- **Author:** AgriciDaniel ([@AgriciDaniel](https://github.com/AgriciDaniel))
- **Source:** https://github.com/AgriciDaniel/claude-obsidian
- **License:** MIT
- **Used for:** Vault layout, dot-prefixed `.raw/` discipline, `wiki/hot.md` session bridge, six-mode framework, `_templates/` pattern, custom callouts (`[!contradiction]`, `[!gap]`, `[!key-insight]`, `[!stale]`), three-depth query (Quick / Standard / Deep), 8-check lint baseline, `dashboard.base` Bases dashboard, inherited skills (`autoresearch`, `canvas`, `save`, `defuddle`, `obsidian-bases`, `obsidian-markdown`), `setup-vault.sh`, hook patterns. The original repository was the starting point of this fork.

### obsidian-wiki (multi-agent + retrieval primitives)
- **Author:** Ar9av ([@Ar9av](https://github.com/Ar9av))
- **Source:** https://github.com/Ar9av/obsidian-wiki
- **License:** MIT
- **Used for:** `summary:` frontmatter field as load-bearing for cheap retrieval, retrieval-primitives ladder (frontmatter grep → `summary:` → sectioned grep → full read), provenance markers (`^[inferred]`, `^[ambiguous]`), `provenance:` frontmatter block, content-trust boundary, `cross-linker` scoring algorithm, `tag-taxonomy` skill, `wiki-status` insights mode (anchor pages, bridge pages, surprising connections), `wiki-rebuild` with `archive-meta.json` discipline, `wiki-export` graph formats (NetworkX / GraphML / Cypher / vis.js HTML), `_meta/taxonomy.md` single-source-of-truth pattern, `misc/` affinity-promotion pattern, `_raw/` in-vault drafts staging, the four-tier escalation table.

---

## Bundled assets

### ITS CSS Snippets
- **Author:** SlRvb
- **Source:** https://github.com/SlRvb/Obsidian--ITS-Theme
- **License:** GPL-2.0
- **Files:**
  - `.obsidian/snippets/ITS-Dataview-Cards.css`
  - `.obsidian/snippets/ITS-Image-Adjustments.css`

These snippets are distributed under the GPL-2.0 license. Per GPL-2.0 terms, any modifications to these files must also be released under GPL-2.0.

### Obsidian Plugins (pre-installed)

The following community plugins ship with this vault as pre-installed binaries. They are the property of their respective authors and are distributed here solely to reduce setup friction. Verify license terms via each plugin's repository:

| Plugin | Author | Repository |
|--------|--------|-----------|
| Calendar | Liam Cain | https://github.com/liamcain/obsidian-calendar-plugin |
| Thino | Boninall (Quorafind) | https://github.com/Quorafind/Obsidian-Thino |
| Obsidian Excalidraw | Zsolt Viczian | https://github.com/zsviczian/obsidian-excalidraw-plugin |
| Obsidian Banners | Danny Hernandez | https://github.com/noatpad/obsidian-banners |

`obsidian-excalidraw-plugin/main.js` is **not** included in this repository. It is downloaded automatically by `bin/setup-vault.sh` from the plugin's official GitHub releases.

---

## This synthesis

- **Synthesizer:** obsidian-wiki super setup contributors
- **License:** MIT (see [LICENSE](LICENSE))
- **Schema version:** 2.0.0

This vault forks AgriciDaniel/claude-obsidian as its base, then absorbs `summary:`/`provenance:`/retrieval-primitives/cross-linker/`tag-taxonomy`/`wiki-status`/`wiki-rebuild`/`wiki-export` from Ar9av/obsidian-wiki, and adds the conceptual layer (provenance discipline, supersession, self-healing lint, content-trust boundary, confidence scoring) from rohitg00 and the original framing from Karpathy.
