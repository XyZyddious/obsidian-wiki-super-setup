#!/usr/bin/env bash
# obsidian-wiki super setup — vault setup script
# Run this ONCE before opening Obsidian for the first time on a fresh vault.
# Usage: bash bin/setup-vault.sh [optional: /path/to/vault]
# Default: uses the directory where this script lives (the vault root)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT="${1:-$(dirname "$SCRIPT_DIR")}"
OBSIDIAN="$VAULT/.obsidian"

echo "Setting up obsidian-wiki super setup at: $VAULT"

# ── 1. Create directories (idempotent) ───────────────────────────────────────
mkdir -p "$OBSIDIAN/snippets"
mkdir -p "$VAULT/.raw"
mkdir -p "$VAULT/.archive"
mkdir -p "$VAULT/_attachments/wiki-export"
mkdir -p "$VAULT/_templates"
mkdir -p "$VAULT/wiki/concepts" "$VAULT/wiki/entities" "$VAULT/wiki/sources" \
         "$VAULT/wiki/comparisons" "$VAULT/wiki/questions" "$VAULT/wiki/references" \
         "$VAULT/wiki/projects" "$VAULT/wiki/journal" "$VAULT/wiki/misc" \
         "$VAULT/wiki/_raw" "$VAULT/wiki/meta"

# ── 2. Write graph.json ──────────────────────────────────────────────────────
cat > "$OBSIDIAN/graph.json" << 'EOF'
{
  "collapse-filter": false,
  "search": "path:wiki",
  "showTags": false,
  "showAttachments": false,
  "hideUnresolved": true,
  "showOrphans": false,
  "collapse-color-groups": false,
  "colorGroups": [
    { "query": "path:wiki/entities",     "color": { "a": 1, "rgb": 12945088 } },
    { "query": "path:wiki/concepts",     "color": { "a": 1, "rgb": 5227007  } },
    { "query": "path:wiki/sources",      "color": { "a": 1, "rgb": 6986069  } },
    { "query": "path:wiki/comparisons",  "color": { "a": 1, "rgb": 11491326 } },
    { "query": "path:wiki/questions",    "color": { "a": 1, "rgb": 16776960 } },
    { "query": "path:wiki/projects",     "color": { "a": 1, "rgb": 16737095 } },
    { "query": "path:wiki/journal",      "color": { "a": 1, "rgb": 9408463  } },
    { "query": "path:wiki/meta",         "color": { "a": 1, "rgb": 5676246  } },
    { "query": "path:wiki",              "color": { "a": 1, "rgb": 5676246  } }
  ],
  "showArrow": true,
  "textFadeMultiplier": -1,
  "nodeSizeMultiplier": 1.8,
  "lineSizeMultiplier": 1.2,
  "centerStrength": 0.5,
  "repelStrength": 30,
  "linkStrength": 1.5,
  "linkDistance": 120,
  "scale": 1.0
}
EOF

# ── 3. Write app.json (excluded files) ───────────────────────────────────────
cat > "$OBSIDIAN/app.json" << 'EOF'
{
  "userIgnoreFilters": [
    "agents/",
    "commands/",
    "hooks/",
    "skills/",
    "_templates/",
    ".raw/",
    ".archive/",
    "_attachments/wiki-export/",
    "README.md",
    "CLAUDE.md",
    "WIKI.md",
    "AGENTS.md",
    "GEMINI.md",
    "ATTRIBUTION.md"
  ]
}
EOF

# ── 4. Write appearance.json (enable CSS snippets) ───────────────────────────
cat > "$OBSIDIAN/appearance.json" << 'EOF'
{
  "enabledCssSnippets": [
    "vault-colors",
    "ITS-Dataview-Cards",
    "ITS-Image-Adjustments"
  ]
}
EOF

# ── 5. Download Excalidraw main.js if needed ─────────────────────────────────
EXCALIDRAW="$OBSIDIAN/plugins/obsidian-excalidraw-plugin"
if [ -f "$EXCALIDRAW/manifest.json" ] && [ ! -f "$EXCALIDRAW/main.js" ]; then
  echo "Downloading Excalidraw main.js (~8MB)..."
  curl -sS -L \
    "https://github.com/zsviczian/obsidian-excalidraw-plugin/releases/latest/download/main.js" \
    -o "$EXCALIDRAW/main.js"
  echo "✓ Excalidraw main.js downloaded"
elif [ -f "$EXCALIDRAW/main.js" ]; then
  echo "✓ Excalidraw main.js already present"
fi

echo ""
echo "✓ Setup complete."
echo ""
echo "Next steps:"
echo "  1. Open Obsidian"
echo "  2. Manage Vaults → Open folder as vault → select: $VAULT"
echo "  3. Enable community plugins when prompted"
echo "  4. Optional: install Dataview, Templater, Obsidian Bases (for wiki/meta/dashboard.md)"
echo "  5. In Claude Code (or any Agent-Skills-compatible agent): type /wiki"
echo ""
echo "What's set up:"
echo "  - 11 wiki/ subfolders (concepts, entities, sources, comparisons, questions,"
echo "    references, projects, journal, misc, _raw, meta) with _index.md scaffolding"
echo "  - 8 templates in _templates/ (source, entity, concept, comparison, question,"
echo "    project, decision, meeting) — all carry summary + provenance + confidence"
echo "  - 14 wiki skills in skills/ (wiki, wiki-ingest, wiki-query, wiki-lint,"
echo "    wiki-status, cross-linker, tag-taxonomy, wiki-rebuild, wiki-export,"
echo "    humanize, wiki-publish-check, wiki-daily, wiki-search, wiki-migrate)"
echo "  - Plus inherited utilities (autoresearch, canvas, save, defuddle,"
echo "    obsidian-bases, obsidian-markdown)"
echo "  - .raw/ ready for source documents (with .manifest.json schema)"
echo "  - .archive/ for snapshots before destructive ops"
echo ""
echo "CSS snippets enabled:"
echo "  - vault-colors: color-codes wiki/ folders in file explorer"
echo "  - ITS-Dataview-Cards: use \`\`\`dataviewjs with .cards for card grids"
echo "  - ITS-Image-Adjustments: append |100 to image embeds for sizing"
echo ""
echo "Read first:"
echo "  - CLAUDE.md (the contract)"
echo "  - WIKI.md (full schema reference)"
echo "  - README.md (vault description)"
echo ""
echo "Drop a source into .raw/ and say 'ingest <filename>' to begin."
