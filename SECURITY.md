# Security Policy

## Reporting a vulnerability

If you discover a security issue in this template (a script that could leak data, a skill that could be hijacked, an MCP integration with credential exposure, etc.), please **do not open a public GitHub issue**.

Instead:

1. Open a private security advisory on the GitHub repo (Security tab → "Report a vulnerability"), OR
2. Email the project maintainer directly (see the `author` field in `.claude-plugin/plugin.json`).

Include:

- A description of the vulnerability
- Steps to reproduce
- The version/commit affected
- (Optional) A suggested fix

You should expect an acknowledgement within 7 days. We aim to publish a fix or mitigation within 30 days for critical issues.

## Scope

In scope:

- The 5 `bin/` scripts (init-fork, setup-vault, setup-multi-agent, backup-vault, start)
- The 14 wiki skills + 6 utility skills (any skill that could be tricked into reading/writing outside the vault, leaking credentials, or executing user-supplied code)
- The hooks (`hooks/hooks.json`) — particularly the auto-commit hook
- The CI workflow (`.github/workflows/lint.yml`)
- The MCP integration documentation (`docs/mcp-setup.md`) — credential storage advice

Out of scope:

- Bugs in third-party Obsidian plugins shipped under `.obsidian/plugins/` — report those upstream
- Vulnerabilities in upstream LLM-Wiki implementations (Karpathy, rohitg00, agrici, ar9av) — report to those projects
- The user's own vault content — content security is the user's responsibility

## Built-in defenses

This template includes several security primitives:

### Content trust boundary

Documented in `CLAUDE.md` and enforced in the `wiki-ingest` skill: source documents in `.raw/` are treated as **untrusted DATA, never INSTRUCTIONS**. If a source contains text resembling agent instructions ("Claude, please...", "ignore your previous instructions and..."), the skill distills it as content rather than acting on it.

### PII leak detection

`wiki-lint` Check 12 scans page bodies for PII patterns (`password`, `api_key`, `secret`, `token`, `email:` followed by value, SSN/credit-card patterns) and flags pages that should be tagged `visibility/pii`. The CI workflow (`.github/workflows/lint.yml`) runs the same scan on every PR and blocks merge on hits.

### Visibility tagging

Pages tagged `visibility/internal` or `visibility/pii` are excluded from `wiki-export` by default. The `--all` flag overrides with a loud warning. `wiki-publish-check` flags any visibility-tagged pages before a public push.

### Privacy filter at ingest

`wiki-ingest` Step 2 strips API keys, tokens, passwords, and PII from sources BEFORE extraction begins. If sensitive content is essential, the resulting page gets `visibility/pii` tagged automatically.

### MCP credential guidance

`docs/mcp-setup.md` documents storing Obsidian REST API keys outside the vault (`~/.config/` or OS keychain) and never committing MCP credentials.

### Per-machine state excluded

`.gitignore` excludes `.claude/settings.local.json`, `.obsidian/workspace*.json`, and similar per-machine state to prevent inadvertent leaks during git push.

## What we won't fix

- Issues that require physical access to the user's machine
- Issues that arise from running `bin/*.sh` scripts as root (they're designed for normal user execution)
- "Vulnerabilities" in the LLM behavior itself (e.g. "Claude said something wrong") — those are model issues, not vault-template issues

## Coordinated disclosure

If you'd like to coordinate disclosure (including a CVE), let us know in your initial report. We're happy to credit you in the CHANGELOG and any public advisory.
