#!/usr/bin/env bash
# obsidian-wiki super setup — Single entry point for new forkers
#
# Run this ONCE after cloning. Detects what's already done and runs the
# remaining steps in the right order:
#
#   1. init-fork.sh        → Personalize the fork (your name, git config, voice sample)
#   2. setup-vault.sh      → Configure Obsidian (graph, snippets, app config)
#   3. setup-multi-agent.sh → (Optional) Symlink skills for Codex/Cursor/Windsurf/Gemini
#
# Skips any step that's already complete. Idempotent — safe to re-run.
#
# Usage: bash bin/start.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
NC='\033[0m'

PLACEHOLDER="obsidian-wiki super setup contributors"

# ── Banner ───────────────────────────────────────────────────────────────────
echo
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   obsidian-wiki super setup — start                              ║${NC}"
echo -e "${CYAN}║   Synthesizes Karpathy + rohitg00 + agrici + ar9av into one      ║${NC}"
echo -e "${CYAN}║   LLM-maintained, persistent, compounding knowledge base.        ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo

# ── State detection ──────────────────────────────────────────────────────────

# Step 1: has init-fork been run? (check for placeholder in LICENSE)
NEEDS_INIT_FORK=0
if grep -q "$PLACEHOLDER" LICENSE 2>/dev/null; then
  NEEDS_INIT_FORK=1
fi

# Step 2: has setup-vault been run? (check for .obsidian/graph.json)
NEEDS_SETUP_VAULT=0
if [ ! -f ".obsidian/graph.json" ] || [ ! -f ".obsidian/app.json" ]; then
  NEEDS_SETUP_VAULT=1
fi

# Print state summary
echo -e "${GRAY}Detected state:${NC}"
if [ "$NEEDS_INIT_FORK" -eq 1 ]; then
  echo -e "  ${YELLOW}⚠ Fork not yet personalized${NC} — placeholders still in LICENSE/ATTRIBUTION/plugin.json"
else
  echo -e "  ${GREEN}✓ Fork already personalized${NC}"
fi
if [ "$NEEDS_SETUP_VAULT" -eq 1 ]; then
  echo -e "  ${YELLOW}⚠ Obsidian config not set up${NC} — graph.json and app.json missing"
else
  echo -e "  ${GREEN}✓ Obsidian config present${NC}"
fi
echo

# ── Quick exit if nothing to do ──────────────────────────────────────────────
if [ "$NEEDS_INIT_FORK" -eq 0 ] && [ "$NEEDS_SETUP_VAULT" -eq 0 ]; then
  echo -e "${GREEN}Everything is already set up.${NC}"
  echo
  echo "Optional next steps:"
  echo "  - bash bin/setup-multi-agent.sh   (symlink skills for Codex/Cursor/Windsurf/Gemini)"
  echo "  - bash bin/backup-vault.sh        (one-time backup test)"
  echo "  - Open the vault in Obsidian and type /wiki in Claude Code"
  echo
  exit 0
fi

# ── Confirm before proceeding ────────────────────────────────────────────────
echo "I'll run the following:"
[ "$NEEDS_INIT_FORK" -eq 1 ] && echo "  1. bin/init-fork.sh        — personalize your fork"
[ "$NEEDS_SETUP_VAULT" -eq 1 ] && echo "  2. bin/setup-vault.sh      — configure Obsidian"
echo "  3. (optional) bin/setup-multi-agent.sh — multi-agent skill discovery"
echo
read -rp "Continue? [Y/n] " confirm
if [[ "$confirm" =~ ^[Nn]$ ]]; then
  echo "Aborted."
  exit 0
fi
echo

# ── Step 1: init-fork ────────────────────────────────────────────────────────
if [ "$NEEDS_INIT_FORK" -eq 1 ]; then
  echo -e "${CYAN}═══ Step 1: Personalize fork ═══${NC}"
  bash bin/init-fork.sh
  echo
fi

# ── Step 2: setup-vault ──────────────────────────────────────────────────────
if [ "$NEEDS_SETUP_VAULT" -eq 1 ]; then
  echo -e "${CYAN}═══ Step 2: Configure Obsidian ═══${NC}"
  bash bin/setup-vault.sh
  echo
fi

# ── Step 3: multi-agent (optional) ───────────────────────────────────────────
echo -e "${CYAN}═══ Step 3: Multi-agent skill discovery (optional) ═══${NC}"
echo
echo "If you use any of: Codex CLI, OpenCode, Cursor, Windsurf, Gemini CLI —"
echo "this step symlinks the skills/ directory into each agent's expected location."
echo
echo "Skip if you only use Claude Code (the .claude-plugin/ manifest auto-discovers there)."
echo
read -rp "Run setup-multi-agent.sh now? [y/N] " run_multi
if [[ "$run_multi" =~ ^[Yy]$ ]]; then
  bash bin/setup-multi-agent.sh
  echo
fi

# ── Final summary ────────────────────────────────────────────────────────────
echo
echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ Setup complete                                               ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
echo
echo "Next steps:"
echo
echo -e "  ${GREEN}1.${NC} Open the vault in Obsidian:"
echo "       Manage Vaults → Open folder as vault → select this directory"
echo
echo -e "  ${GREEN}2.${NC} Open Claude Code (or another Agent Skills client) in this directory"
echo
echo -e "  ${GREEN}3.${NC} Type ${YELLOW}/wiki${NC} to verify everything is wired up"
echo
echo -e "  ${GREEN}4.${NC} Drop a sample source into .raw/ and try the workflow:"
echo "       cp examples/article.md .raw/"
echo "       (then in Claude Code) ingest .raw/article.md"
echo
echo -e "${GRAY}Read first if you haven't:${NC}"
echo "  - CLAUDE.md       (the contract — vault rules and conventions)"
echo "  - WIKI.md         (full schema reference)"
echo "  - README.md       (vault overview)"
echo "  - docs/plugins.md (recommended Obsidian plugins)"
echo
echo -e "${GRAY}When you're ready to publish your fork to GitHub:${NC}"
echo "  - Run bash bin/backup-vault.sh first (one-time backup of clean state)"
echo "  - In Claude Code: 'publish-check' to audit publish-readiness"
echo "  - git add . && git commit -m 'Initial commit' && git push"
echo
