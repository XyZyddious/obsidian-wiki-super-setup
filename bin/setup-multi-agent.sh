#!/usr/bin/env bash
# obsidian-wiki super setup: multi-agent skill installer
# Symlinks the skills/ directory into each AI agent's expected location.
# Idempotent: safe to run multiple times.
#
# Tier 1 — formal bootstrap support:
#   - Claude Code    : auto-discovered via .claude-plugin/ (no symlink needed)
#   - Codex CLI      : symlink to ~/.codex/skills/obsidian-wiki        (uses AGENTS.md)
#   - OpenCode       : symlink to ~/.opencode/skills/obsidian-wiki     (uses AGENTS.md)
#   - Gemini CLI     : symlink to ~/.gemini/skills/obsidian-wiki       (uses GEMINI.md)
#   - Cursor         : symlink to .cursor/skills (workspace-local)     (uses .cursor/rules/)
#   - Windsurf       : symlink to .windsurf/skills (workspace-local)   (uses .windsurf/rules/)
#   - Kiro           : symlink to .kiro/skills (workspace-local)       (uses .kiro/steering/)
#   - Antigravity    : symlink to .agents/skills (workspace-local)     (uses .agent/rules/ + .agent/workflows/)
#   - GitHub Copilot : no symlink (reads .github/copilot-instructions.md directly)
#
# Tier 2 — spec-compatible (uses AGENTS.md natively):
#   - Aider          : symlink to ~/.aider/skills/obsidian-wiki
#   - Hermes         : symlink to ~/.hermes/skills/obsidian-wiki       (also uses .hermes.md alias)
#   - OpenClaw       : symlink to ~/.openclaw/skills/obsidian-wiki
#   - Kilocode       : symlink to ~/.kilocode/skills/obsidian-wiki
#   - Trae           : symlink to ~/.trae/skills/obsidian-wiki
#
# Bootstrap files (CLAUDE.md, AGENTS.md, GEMINI.md, .hermes.md, .cursor/rules/,
# .windsurf/rules/, .github/copilot-instructions.md, .kiro/steering/,
# .agent/rules/, .agent/workflows/) are already committed in the repo.
# This script just wires up the skills directory for runtime discovery.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "ERROR: $SKILLS_DIR does not exist. Are you running this from the obsidian-wiki super setup vault?"
  exit 1
fi

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
GRAY='\033[0;37m'
NC='\033[0m'

link_if_missing() {
  local target="$1"
  local dest="$2"
  local agent_name="$3"

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ]; then
    local existing="$(readlink "$dest")"
    if [ "$existing" = "$target" ]; then
      echo -e "${GRAY}[$agent_name] already linked: $dest${NC}"
      return
    else
      echo -e "${YELLOW}[$agent_name] symlink exists but points elsewhere: $dest -> $existing (skipping, remove manually if you want to relink)${NC}"
      return
    fi
  fi

  if [ -e "$dest" ]; then
    echo -e "${YELLOW}[$agent_name] path exists and is not a symlink: $dest (skipping)${NC}"
    return
  fi

  ln -s "$target" "$dest"
  echo -e "${GREEN}[$agent_name] linked: $dest -> $target${NC}"
}

echo "obsidian-wiki super setup: multi-agent skill installer"
echo "Repo: $REPO_ROOT"
echo

# ── Tier 1: agents with formal bootstrap files in this repo ────────────────
echo "Tier 1 — agents with full bootstrap support:"

# Codex CLI (uses AGENTS.md)
link_if_missing "$SKILLS_DIR" "$HOME/.codex/skills/obsidian-wiki" "Codex CLI"

# OpenCode (uses AGENTS.md)
link_if_missing "$SKILLS_DIR" "$HOME/.opencode/skills/obsidian-wiki" "OpenCode"

# Gemini CLI (uses GEMINI.md)
link_if_missing "$SKILLS_DIR" "$HOME/.gemini/skills/obsidian-wiki" "Gemini CLI"

# Cursor (workspace-local; uses .cursor/rules/claude-obsidian.mdc)
link_if_missing "$SKILLS_DIR" "$REPO_ROOT/.cursor/skills" "Cursor"

# Windsurf (workspace-local; uses .windsurf/rules/claude-obsidian.md)
link_if_missing "$SKILLS_DIR" "$REPO_ROOT/.windsurf/skills" "Windsurf"

# Kiro (workspace-local; uses .kiro/steering/obsidian-wiki.md)
link_if_missing "$SKILLS_DIR" "$REPO_ROOT/.kiro/skills" "Kiro"

# Antigravity (workspace-local; uses .agent/rules/ and .agent/workflows/)
link_if_missing "$SKILLS_DIR" "$REPO_ROOT/.agents/skills" "Antigravity"

echo
echo "Tier 2 — spec-compatible agents (use AGENTS.md natively):"

# Aider (uses AGENTS.md)
link_if_missing "$SKILLS_DIR" "$HOME/.aider/skills/obsidian-wiki" "Aider"

# Hermes (uses .hermes.md → AGENTS.md)
link_if_missing "$SKILLS_DIR" "$HOME/.hermes/skills/obsidian-wiki" "Hermes"

# OpenClaw (uses AGENTS.md)
link_if_missing "$SKILLS_DIR" "$HOME/.openclaw/skills/obsidian-wiki" "OpenClaw"

# Kilocode (uses AGENTS.md)
link_if_missing "$SKILLS_DIR" "$HOME/.kilocode/skills/obsidian-wiki" "Kilocode"

# Trae (uses AGENTS.md)
link_if_missing "$SKILLS_DIR" "$HOME/.trae/skills/obsidian-wiki" "Trae"

echo
echo -e "${GREEN}Done.${NC}"
echo
echo "Bootstrap files (always present in repo):"
echo "  - CLAUDE.md                                  → Claude Code"
echo "  - AGENTS.md                                  → Codex, OpenCode, Aider, Hermes, OpenClaw, Kilocode, Trae"
echo "  - GEMINI.md                                  → Gemini CLI / Antigravity (legacy)"
echo "  - .hermes.md                                 → Hermes (alias to AGENTS.md)"
echo "  - .cursor/rules/claude-obsidian.mdc          → Cursor"
echo "  - .windsurf/rules/claude-obsidian.md         → Windsurf"
echo "  - .github/copilot-instructions.md            → GitHub Copilot (VS Code)"
echo "  - .kiro/steering/obsidian-wiki.md            → Kiro"
echo "  - .agent/rules/obsidian-wiki.md              → Antigravity (always-on rules)"
echo "  - .agent/workflows/obsidian-wiki.md          → Antigravity (slash-command registry)"
echo
echo "To verify each agent picks up the skills:"
echo "  - Claude Code:  open the project, type /wiki"
echo "  - Codex CLI:    codex --list-skills | grep obsidian-wiki"
echo "  - OpenCode:     opencode --list-skills | grep obsidian-wiki"
echo "  - Cursor:       open the project, ask 'what skills do you have?'"
echo "  - Windsurf:     open in Cascade, ask the same"
echo "  - Gemini CLI:   gemini --list-skills (if supported)"
echo "  - Kiro:         open project, ask 'list available skills'"
echo "  - Antigravity:  open project, /wiki should appear in slash-command palette"
echo "  - Aider/Hermes/OpenClaw/Kilocode/Trae: each agent's docs vary; check '$HOME/.<agent>/skills/' for the symlink"
