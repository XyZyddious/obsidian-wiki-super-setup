#!/usr/bin/env bash
# obsidian-wiki super setup — backup script
# Creates a timestamped tarball of the vault for off-machine backup.
# Optionally pushes to a backup git remote if one is configured.
#
# Usage:
#   bash bin/backup-vault.sh                           # default: tarball to ~/Backups/
#   bash bin/backup-vault.sh --dest /path/to/backups   # custom destination
#   bash bin/backup-vault.sh --git                     # also push to backup remote
#   bash bin/backup-vault.sh --git-only                # only push (no tarball)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Defaults
DEST="${HOME}/Backups"
DO_TARBALL=1
DO_GIT=0

# Parse args
while [ $# -gt 0 ]; do
  case "$1" in
    --dest)
      DEST="$2"
      shift 2
      ;;
    --git)
      DO_GIT=1
      shift
      ;;
    --git-only)
      DO_GIT=1
      DO_TARBALL=0
      shift
      ;;
    -h|--help)
      grep '^#' "$0" | head -10
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      exit 1
      ;;
  esac
done

TS=$(date '+%Y-%m-%dT%H%M%S')
VAULT_NAME=$(basename "$REPO_ROOT")
ARCHIVE_NAME="${VAULT_NAME}-backup-${TS}.tar.gz"

echo
echo -e "${GREEN}obsidian-wiki backup${NC}"
echo "Vault: $REPO_ROOT"
echo "Timestamp: $TS"
echo

# ── 1. Tarball backup ────────────────────────────────────────────────────────
if [ "$DO_TARBALL" -eq 1 ]; then
  mkdir -p "$DEST"

  echo -e "${GREEN}→ Creating tarball...${NC}"
  echo "  Destination: $DEST/$ARCHIVE_NAME"

  # Exclude .git/ (large, easy to recreate via git clone)
  # Exclude .archive/ (snapshots already; nested backup is wasteful)
  # Exclude .obsidian/workspace*.json (per-machine UI state)
  # Include everything else
  tar \
    --exclude="./.git" \
    --exclude="./.archive" \
    --exclude="./.obsidian/workspace.json" \
    --exclude="./.obsidian/workspace-mobile.json" \
    --exclude="./.obsidian/workspace-visual.json" \
    --exclude="./node_modules" \
    --exclude="./.DS_Store" \
    -czf "$DEST/$ARCHIVE_NAME" .

  SIZE=$(du -h "$DEST/$ARCHIVE_NAME" | cut -f1)
  echo "  ✓ Tarball created ($SIZE)"
  echo
fi

# ── 2. Git backup remote push ────────────────────────────────────────────────
if [ "$DO_GIT" -eq 1 ]; then
  if [ ! -d ".git" ]; then
    echo -e "${YELLOW}⚠ Not a git repo — skipping git push${NC}"
    echo
  elif ! git remote get-url backup >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ No 'backup' remote configured — skipping git push${NC}"
    echo "  To set up a backup remote (one-time):"
    echo "    git remote add backup <url>     # e.g. git@gitlab.com:you/wiki-backup.git"
    echo
  else
    echo -e "${GREEN}→ Pushing to backup remote...${NC}"
    BACKUP_URL=$(git remote get-url backup)
    echo "  Remote: $BACKUP_URL"

    # Get current branch
    BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "main")

    # Push (force-with-lease for safety; backup remote is just a mirror)
    if git push backup "$BRANCH" --force-with-lease; then
      echo "  ✓ Pushed $BRANCH to backup remote"
    else
      echo -e "${RED}  ✗ Push failed${NC}"
      exit 1
    fi
    echo
  fi
fi

# ── 3. Retention check (optional cleanup) ────────────────────────────────────
if [ "$DO_TARBALL" -eq 1 ] && [ -d "$DEST" ]; then
  echo -e "${GREEN}→ Retention check (keeping last 30 backups)...${NC}"
  COUNT=$(ls -t "$DEST"/${VAULT_NAME}-backup-*.tar.gz 2>/dev/null | wc -l | tr -d ' ')
  echo "  Backups in $DEST: $COUNT"
  if [ "$COUNT" -gt 30 ]; then
    OLD=$(ls -t "$DEST"/${VAULT_NAME}-backup-*.tar.gz | tail -n +31)
    echo "  Removing $(echo "$OLD" | wc -l | tr -d ' ') old backup(s):"
    echo "$OLD" | sed 's/^/    /'
    echo "$OLD" | xargs rm -f
  fi
  echo
fi

echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Backup complete${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo
echo "Set up scheduled backups (optional):"
echo "  Add to crontab: 0 9 * * 1 cd $REPO_ROOT && bash bin/backup-vault.sh"
echo "  (Mondays at 9am — adjust as needed)"
echo
