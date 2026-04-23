# Contributing

Thanks for your interest in contributing to obsidian-wiki super setup. This document covers PR conventions, the lint workflow, and the few rules that keep the system coherent.

## What this project is

A template repo for an LLM-maintained Obsidian wiki. Forkers customize it for their own knowledge work. Contributions go to the **template itself** — skill bodies, templates, schema, scripts, docs — not to anyone's personal vault content.

## Before you start

1. Read `CLAUDE.md` (the vault contract) — the universal frontmatter spec, the 14-check lint, the content-trust boundary.
2. Read `WIKI.md` (the deep schema reference) — section 11 has the writing-style discipline that all new skill bodies must follow.
3. Run `bash bin/start.sh` once locally to verify your fork builds and you can ingest `examples/article.md` end-to-end.

## Pull request conventions

### Scope

One concern per PR. If you're adding a skill AND fixing a lint check AND updating docs, that's three PRs. Keeps review fast.

### Title

Imperative + scope, ≤72 chars:
- `add skills/wiki-foo for X`
- `fix wiki-lint check 11 false positive on small tag clusters`
- `update README quick-start ordering`

### Description

A short paragraph: what changed, why, and what to verify. Don't paste full diffs — the PR view shows them.

### Required for skill changes

Every PR that adds or modifies a skill must:

1. Update or add the corresponding `commands/<skill-name>.md` slash-command file.
2. Update the skill's mention in `CLAUDE.md`, `README.md`, `WIKI.md`, `AGENTS.md`, `GEMINI.md` (skill count, table entries).
3. If the skill writes wiki pages, reference `skills/wiki/references/writing-style.md` and `skills/wiki/references/frontmatter.md` in its reading list.
4. Bump `wiki/overview.md` schema version note (minor for new skills, major for breaking changes to existing skills).
5. Add a CHANGELOG.md entry under the new version.

## Lint workflow

The CI workflow at `.github/workflows/lint.yml` runs on every PR. It validates:

- Manifest schema (`.raw/.manifest.json`) is valid JSON with version 1
- Every wiki page has the required frontmatter fields
- Every template has the required frontmatter fields
- Every SKILL.md uses ONLY `name` and `description` frontmatter (Agent Skills spec compliance)
- Skill `name` matches its directory
- No personal-info patterns leak (emails, hostnames, API keys)
- AI-writing tell density on synthesis-heavy pages (warning only)

Failed CI blocks merge. Run locally before opening:

```bash
# (in a vault with content)
# lint the wiki      # via the wiki-lint skill in Claude Code
# Or just check spec compliance manually:
python3 -c "import yaml, os; ..."
```

## Frontmatter discipline (HARD requirement)

Every page must carry `type, title, created, updated, tags, status, summary (≤200 chars), provenance, confidence`. New page types require a template in `_templates/` AND an entry in the universal-frontmatter spec at `skills/wiki/references/frontmatter.md`.

## Tag discipline

Don't add tags ad-hoc. Canonical tags live in `wiki/meta/taxonomy.md`. New tags require either:

1. Going through `tag-taxonomy add` (the documented flow), OR
2. A PR that updates `taxonomy.md` with the new entry, including its alias list and which section it belongs to (Type / Domain / Status / Project / Visibility).

## Writing-style discipline

Skill bodies, doc files, and scaffold pages should follow `skills/wiki/references/writing-style.md`. The lint Check 13 will flag drift. Specifically:

- No "delve into", "tapestry", "vibrant", "navigate the complexities", "boasts", "showcases" without genuine necessity
- No "not just X, but Y" structures
- Sentence-case headings inside body content
- No em-dash density above ~1 per paragraph
- No filler ("in order to", "it's worth noting that", "needless to say")
- No generic wrap-up conclusions

## Schema version

The version in `wiki/overview.md` must match the latest CHANGELOG entry. Bump rules:

- **Major**: breaking change to universal frontmatter, vault layout, or skill spec
- **Minor**: new skill, new check, new convention without breaking existing pages
- **Patch**: bug fix, documentation clarification, minor scaffolding tweak

`wiki-lint` Check 14 detects drift if `CLAUDE.md` is edited but the version note isn't bumped.

## What NOT to PR

- Personal vault content (concepts/entities/sources/etc. for your own use) — that's for your fork, not this template
- Per-machine config (`.obsidian/workspace.json`, `.claude/settings.local.json`) — already in `.gitignore`
- Inherited skill modifications (`skills/canvas`, `skills/defuddle`, etc.) without coordinating with upstream — those are MIT'd from other authors and should track their canonical versions

## Reporting issues

Open a GitHub issue with:

- What you expected vs what happened
- Steps to reproduce (which agent, which command, which file)
- Vault state (`bash bin/start.sh` output is helpful)
- Schema version (from `wiki/overview.md`)

For security issues, see `SECURITY.md`.

## Code of conduct

This project follows the contributor covenant — see `CODE_OF_CONDUCT.md`.

## Attribution

This project synthesizes upstream work from Karpathy, rohitg00, AgriciDaniel, and Ar9av. Contributions to the synthesis itself are welcome; contributions to the upstream patterns should go to those projects directly. See `ATTRIBUTION.md` for credits and links.
