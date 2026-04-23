# Backup Strategy

The vault uses a defense-in-depth backup approach. Three layers, each addresses a different failure mode.

---

## Layer 1: Auto-commit hook (in-session protection)

The `PostToolUse` hook in `hooks/hooks.json` automatically commits every change to `wiki/` and `.raw/` after every Write or Edit operation.

**Protects against:** session-internal mistakes, accidental file overwrites, partial work loss.

**Limitation:** all commits stay on your local machine. If your disk dies, everything is gone.

**No setup required** — the hook ships with the vault and runs whenever Claude Code is active.

---

## Layer 2: Tarball backups (off-machine protection)

`bin/backup-vault.sh` creates a timestamped `.tar.gz` of the entire vault (excluding `.git/`, `.archive/`, and per-machine Obsidian UI state).

```bash
# Default — backup to ~/Backups/
bash bin/backup-vault.sh

# Custom destination (e.g. to an external drive or synced folder)
bash bin/backup-vault.sh --dest /Volumes/MyDrive/wiki-backups
```

**Protects against:** disk failure, accidental `rm -rf`, ransomware.

**Retention:** keeps the most recent 30 tarballs in the destination dir. Older ones auto-pruned.

**Recommended cadence:**

```bash
# Add to crontab for weekly backup (every Monday 9am)
0 9 * * 1 cd ~/Vaults/your-vault && bash bin/backup-vault.sh
```

Or run manually before any major restructuring.

### Where to put the tarballs

In order of robustness:

1. **External drive that you eject between sessions** — air-gapped, ransomware-safe
2. **Cloud-synced folder** (Dropbox, iCloud, Drive, OneDrive) — automatic off-machine, easy restore
3. **Network-attached storage** — if you have a NAS at home
4. **`~/Backups/` on the same machine** (default) — protects against `rm -rf` of the vault folder, NOT against disk failure

For maximum safety, do at least 2 of the above.

---

## Layer 3: Git backup remote (versioned + off-machine)

Push to a separate "backup" git remote that's not your primary GitHub repo. Combines version history with off-machine durability.

### One-time setup

Choose a backup remote:
- **Private GitLab repo** (free, unlimited private repos)
- **Codeberg** (free, no big-tech)
- **Self-hosted Gitea** (full control)
- **Private GitHub repo** (different account from your main one)

Create an empty repo there, then:

```bash
cd ~/Vaults/your-vault
git remote add backup <url>
# e.g. git@gitlab.com:you/wiki-backup.git
```

### Run the push

```bash
# Push to backup remote (in addition to tarball)
bash bin/backup-vault.sh --git

# Push only (no tarball — useful if you sync git often)
bash bin/backup-vault.sh --git-only
```

The script uses `--force-with-lease` so the backup remote can be wiped/restored cleanly without merge headaches. It's a mirror, not a collaborative remote.

### Why a separate remote?

- Your primary `origin` remote probably has access controls and visibility tied to your published vault
- The backup remote can be private, on a different platform, with different credentials
- If your `origin` repo is deleted, suspended, or compromised, the backup is independent

---

## Restore procedures

### From a tarball

```bash
mkdir restored-vault
cd restored-vault
tar -xzf ~/Backups/your-vault-backup-2026-04-23T120000.tar.gz
# Open the restored folder in Obsidian
```

### From the backup git remote

```bash
git clone <backup-url> restored-vault
cd restored-vault
# Run setup
bash bin/setup-vault.sh
# Open in Obsidian
```

### From the in-session auto-commit history

If something went wrong in the current session and you want to revert:

```bash
git log --oneline | head -20    # find the commit before the mistake
git reset --hard <commit-sha>   # destructive — be sure
```

Or to recover a single file:

```bash
git log --follow -- wiki/concepts/MyPage.md     # see the history of that file
git checkout <commit-sha> -- wiki/concepts/MyPage.md
```

---

## What the auto-commit hook captures vs. the tarball captures

| Item | Auto-commit | Tarball | Git backup |
|---|---|---|---|
| `wiki/` content | ✓ | ✓ | ✓ |
| `.raw/` source files | ✓ | ✓ | ✓ |
| `.raw/.manifest.json` | ✓ | ✓ | ✓ |
| `_templates/` | only when changed | ✓ | ✓ |
| `skills/`, `commands/`, `agents/`, `hooks/` | only when changed | ✓ | ✓ |
| `_attachments/` | not auto (large files) | ✓ | not auto |
| `.obsidian/` config | not auto | ✓ | not auto |
| `.git/` history | n/a (it IS the history) | excluded | n/a |
| `.archive/` snapshots | not auto | excluded (it's already a snapshot) | not auto |

For most users, auto-commit + weekly tarball + occasional git backup remote is plenty.

---

## Recommended minimum

If you do nothing else: schedule a weekly tarball to a cloud-synced folder.

```bash
# crontab -e
0 9 * * 1 cd ~/Vaults/your-vault && bash bin/backup-vault.sh --dest ~/Dropbox/wiki-backups
```

That alone protects against 95% of failure modes. Everything else (git backup remote, external drive, multiple destinations) is hardening.
