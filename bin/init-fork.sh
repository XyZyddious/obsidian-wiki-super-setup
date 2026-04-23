#!/usr/bin/env bash
# obsidian-wiki super setup — interactive forker initialization
# Run this ONCE after cloning/forking. Customizes the placeholders for your fork.
#
# Usage: bash bin/init-fork.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  obsidian-wiki super setup — Fork Initialization${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo
echo "This will customize the vault for your use:"
echo "  1. Set your name as the local copyright holder"
echo "  2. Configure git user.name and user.email for this repo"
echo "  3. Replace 'obsidian-wiki super setup contributors' placeholders"
echo "  4. (Optional) Seed wiki/meta/voice-sample.md for humanize"
echo
read -rp "Continue? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

# ── 1. Get user info ─────────────────────────────────────────────────────────
echo
read -rp "Your name (e.g. 'Jane Doe'): " USER_NAME
read -rp "Your email (e.g. 'jane@example.com'): " USER_EMAIL
read -rp "Your project/vault name (e.g. 'jane-wiki'): " PROJECT_NAME

if [ -z "$USER_NAME" ] || [ -z "$USER_EMAIL" ] || [ -z "$PROJECT_NAME" ]; then
  echo -e "${YELLOW}All three fields required. Aborting.${NC}"
  exit 1
fi

# ── 2. Set git config ────────────────────────────────────────────────────────
echo
echo -e "${GREEN}→ Setting local git config...${NC}"
git config --local user.name "$USER_NAME"
git config --local user.email "$USER_EMAIL"
echo "  user.name  = $USER_NAME"
echo "  user.email = $USER_EMAIL"

# ── 3. Replace placeholders in core files ────────────────────────────────────
echo
echo -e "${GREEN}→ Replacing placeholders...${NC}"

PLACEHOLDER="obsidian-wiki super setup contributors"

# Files known to contain the placeholder (verified by audit)
FILES=(
  "LICENSE"
  "ATTRIBUTION.md"
  ".claude-plugin/plugin.json"
  ".claude-plugin/marketplace.json"
)

for f in "${FILES[@]}"; do
  if [ -f "$f" ]; then
    if grep -q "$PLACEHOLDER" "$f"; then
      # macOS/Linux compatible sed
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|$PLACEHOLDER|$USER_NAME|g" "$f"
      else
        sed -i "s|$PLACEHOLDER|$USER_NAME|g" "$f"
      fi
      echo "  ✓ $f"
    else
      echo "  - $f (no placeholder found, skipping)"
    fi
  fi
done

# ── 4. Optional: rename plugin ───────────────────────────────────────────────
echo
read -rp "Rename plugin from 'obsidian-wiki-super-setup' to '$PROJECT_NAME'? [y/N] " rename_plugin
if [[ "$rename_plugin" =~ ^[Yy]$ ]]; then
  for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s|obsidian-wiki-super-setup|$PROJECT_NAME|g" "$f"
    else
      sed -i "s|obsidian-wiki-super-setup|$PROJECT_NAME|g" "$f"
    fi
    echo "  ✓ $f"
  done
fi

# ── 5. Optional: voice sample ────────────────────────────────────────────────
echo
read -rp "Seed wiki/meta/voice-sample.md for humanize calibration? [y/N] " seed_voice
if [[ "$seed_voice" =~ ^[Yy]$ ]]; then
  echo
  echo "Paste 2-3 paragraphs of your own writing (any content)."
  echo "Press Ctrl-D when done:"
  echo
  USER_VOICE=$(cat)

  cat > wiki/meta/voice-sample.md <<EOF
---
type: meta
title: "Voice Sample"
created: $(date '+%Y-%m-%d')
updated: $(date '+%Y-%m-%d')
tags: [meta, "visibility/internal"]
status: evergreen
summary: User voice sample for humanize calibration. Never exported.
provenance: {extracted: 1.0, inferred: 0.0, ambiguous: 0.0}
confidence: high
---

# Voice Sample

This file is read by the \`humanize\` skill when rewriting wiki prose, to match the user's natural sentence rhythm, vocabulary register, and structural habits. Tagged \`visibility/internal\` so it's never exported.

---

$USER_VOICE
EOF
  echo "  ✓ wiki/meta/voice-sample.md created"
fi

# ── 6. Reset .raw/ and wiki/ for clean slate (optional) ──────────────────────
echo
read -rp "Reset wiki/ and .raw/ for a clean-slate start (you'll lose any sample content)? [y/N] " reset_content
if [[ "$reset_content" =~ ^[Yy]$ ]]; then
  echo "  This is a destructive operation. Type 'yes' to confirm:"
  read -rp "  > " hard_confirm
  if [[ "$hard_confirm" == "yes" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "linux-gnu" ]]; then
      # Reset .raw/ contents but keep .gitkeep and .manifest.json
      find .raw -type f -not -name '.gitkeep' -not -name '.manifest.json' -delete 2>/dev/null
      # Reset .raw/.manifest.json to empty state
      cat > .raw/.manifest.json <<EOF
{
  "version": 1,
  "schema": "obsidian-wiki-super-setup-1.0",
  "last_updated": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
  "sources": {},
  "projects": {},
  "stats": {
    "total_sources_ingested": 0,
    "total_pages": 0,
    "total_projects": 0,
    "last_full_rebuild": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  }
}
EOF
      echo "  ✓ .raw/ reset"
    fi
  else
    echo "  - Reset cancelled."
  fi
fi

# ── 7. Reset scaffolding-page dates to today ─────────────────────────────────
# All wiki/ scaffolding pages ship with the template's build-time `created:`
# and `updated:` dates in their frontmatter. Forkers should see today's date
# instead — those dates ARE supposed to be accurate per-page metadata.
# Only runs if no content has been ingested yet (sources count == 0).

echo
echo -e "${GREEN}→ Resetting scaffolding-page dates to today...${NC}"

TODAY=$(date '+%Y-%m-%d')

# List of scaffolding pages that need date reset
SCAFFOLD_PAGES=(
  "wiki/index.md"
  "wiki/hot.md"
  "wiki/log.md"
  "wiki/overview.md"
  "wiki/meta/taxonomy.md"
  "wiki/meta/dashboard.md"
  "wiki/meta/insights.md"
)
# Plus all _index.md files
while IFS= read -r f; do SCAFFOLD_PAGES+=("$f"); done < <(find wiki -name '_index.md' 2>/dev/null)

UPDATED_COUNT=0
for f in "${SCAFFOLD_PAGES[@]}"; do
  if [ -f "$f" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s/^created: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/created: $TODAY/" "$f"
      sed -i '' "s/^updated: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/updated: $TODAY/" "$f"
    else
      sed -i "s/^created: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/created: $TODAY/" "$f"
      sed -i "s/^updated: [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/updated: $TODAY/" "$f"
    fi
    UPDATED_COUNT=$((UPDATED_COUNT+1))
  fi
done

echo "  ✓ Reset created/updated to $TODAY on $UPDATED_COUNT scaffolding pages"

# Also update the CHANGELOG to note today as the "Initial fork" date if still unannotated
if grep -q "^## \[2.0.0\] — Initial release$" CHANGELOG.md 2>/dev/null; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|^## \[2.0.0\] — Initial release$|## [2.0.0] — $TODAY|" CHANGELOG.md
  else
    sed -i "s|^## \[2.0.0\] — Initial release$|## [2.0.0] — $TODAY|" CHANGELOG.md
  fi
  echo "  ✓ CHANGELOG.md: stamped initial release date as $TODAY"
fi

# Update wiki/overview.md schema-version note to add fork-date qualifier
if grep -q "^\*\*Schema version:\*\* 1.0$" wiki/overview.md 2>/dev/null; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|^\*\*Schema version:\*\* 1.0$|**Schema version:** 1.0 (forked $TODAY)|" wiki/overview.md
  else
    sed -i "s|^\*\*Schema version:\*\* 1.0$|**Schema version:** 1.0 (forked $TODAY)|" wiki/overview.md
  fi
  echo "  ✓ wiki/overview.md: stamped fork date in schema-version note"
fi

# ── 8. Final summary ─────────────────────────────────────────────────────────
echo
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Fork initialization complete${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
echo
echo "Next steps:"
echo "  1. Run: bash bin/setup-vault.sh    (configures Obsidian app/graph/snippets)"
echo "  2. Open the vault in Obsidian: Manage Vaults → Open folder as vault"
echo "  3. Open Claude Code (or your agent) here"
echo "  4. Type /wiki to verify setup"
echo "  5. Drop a source into .raw/ and say 'ingest <filename>'"
echo
echo "When ready to publish to your own GitHub repo:"
echo "  git add ."
echo "  git commit -m 'Initial commit: $PROJECT_NAME'"
echo "  gh repo create $PROJECT_NAME --public --source=. --push"
echo
