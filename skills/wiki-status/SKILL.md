---
name: wiki-status
description: Two-mode status skill. "Delta" mode reports what's pending in .raw/ vs the manifest, recommends append vs rebuild. "Insights" mode does graph analysis — anchor pages, bridges, surprising connections, suggested questions, graph delta. Use when user says "wiki status", "what's pending", "wiki insights", "show hubs", "graph health".
---

# wiki-status

Two modes. Use the right one for the question.

## Mode 1: `delta` (default)

Answers: "What's pending? What changed? Should I append or rebuild?"

### Workflow

1. Read `.raw/.manifest.json`.
2. Walk `.raw/` recursively. For each file, classify:
   - **NEW** — exists in `.raw/` but not in manifest
   - **MODIFIED** — manifest entry exists but `content_hash` differs from current
   - **TOUCHED** — manifest entry exists, content unchanged, but mtime is newer (no-op for ingest, but worth noting)
   - **UNCHANGED** — manifest entry matches current state
   - **DELETED** — manifest entry exists but file is missing from `.raw/`
3. Compute totals per category.
4. Recommend an action:
   - 0 NEW + 0 MODIFIED + 0 DELETED → "Wiki is up-to-date with `.raw/`."
   - Small N (≤10) NEW/MODIFIED, 0 DELETED → "Run `ingest append`."
   - DELETED present OR widespread MODIFIED (>30% of sources) → "Consider `wiki-rebuild` (archive + full re-ingest)."
   - Anything else → "Run `ingest append` first; review afterward."

### Output

Print to chat AND append to `wiki/log.md` as a status entry. Don't write a permanent file (status is ephemeral).

```
Wiki Status Report — 2026-04-23 07:45

.raw/ vs manifest:
  NEW:        3
  MODIFIED:   1
  TOUCHED:    0
  UNCHANGED:  47
  DELETED:    0

Total sources: 51
Total pages:   312
Last full rebuild: 2026-04-23

Recommendation: Run `ingest append` to process 4 changes.
```

---

## Mode 2: `insights` (the graph health pass)

Answers: "What are the hubs? Where are the gaps? What questions should I be asking?"

### Workflow

1. Build the wikilink graph from `wiki/**/*.md`. For each page, parse:
   - Outgoing `[[wikilinks]]`
   - Tags
   - Frontmatter (especially `summary`, `provenance`, `status`)
2. Compute the metrics below.
3. Write the report to `wiki/meta/insights.md` (overwrites the auto-generated section).

### Metrics

#### Anchor pages (top 10 by incoming links)

The hubs of your knowledge. Removing them would cripple the graph. Track in the report with link count + summary.

#### Bridge pages

Pages that are the ONLY path between two otherwise-disconnected components. Compute via component analysis: temporarily remove each page, see if the graph fragments. Report the top 5.

#### Tag cluster cohesion

For each tag with ≥5 pages, compute `actual_internal_links / max_possible_internal_links` where max = `n * (n-1) / 2`. Sort ascending. Flag the bottom 3 as "fragmented — consider running cross-linker scoped to tag."

#### Surprising connections

Pages that link across categories you wouldn't expect (e.g. a `concept` linking heavily to `journal`, or a `decision` linking to a `reference`). Report top 5 — these are often the most interesting.

#### Orphan-adjacent

Pages with only 1 incoming link, OR pages whose only neighbor is itself an orphan. These are at risk of becoming orphans.

#### Graph delta

Compare current graph to the embedded snapshot from the previous insights run.

```html
<!-- GRAPH_SNAPSHOT: {"nodes": N, "edges": E, "density": D, "components": C, "max_component_size": M, "timestamp": "..."} -->
```

Report what changed: nodes added, edges added, density change, component count change.

#### Suggested questions

Auto-generate 5-10 questions worth asking, drawn from:
- Pages with `^[ambiguous]` markers — "Which is true: X or Y?"
- Bridge nodes — "What would happen to the wiki if [[Bridge]] were superseded?"
- Isolated subgraphs — "Why are [[Cluster A]] and [[Cluster B]] disconnected?"
- High-incoming pages with low `confidence` — "Should we re-source [[Hub Page]]?"
- Recent additions with INFERRED > 40% — "Find a primary source for [[Page]]?"

### Output

Overwrite `wiki/meta/insights.md` between the `<!-- BEGIN AUTO-GENERATED -->` and `<!-- END AUTO-GENERATED -->` markers. Update the `<!-- GRAPH_SNAPSHOT: ... -->` HTML comment with the current snapshot.

Append to `wiki/log.md`:

```markdown
## [YYYY-MM-DD HH:MM] insights | graph health pass
- nodes: N | edges: E | density: D | components: C
- delta vs prior: +Δn nodes, +Δe edges
- top hub: [[Page]] (X incoming)
- top bridge: [[Page]]
- fragmented tag: <tag> (cohesion X.XX)
- suggested questions: K
- report: [[wiki/meta/insights]]
```

---

## When to run

- **Delta mode**: weekly, before any large ingest, or any time you're unsure if `.raw/` is up-to-date with the wiki.
- **Insights mode**: weekly, after `cross-linker` runs, or whenever the wiki feels "stuck" (you can't find what you wrote, or queries return weak results).

---

## Writing-style discipline (insights mode)

The insights report is Claude-written prose — apply `skills/wiki/references/writing-style.md`. Specific tells to avoid here: "marks a pivotal" descriptions of hub pages, "vibrant ecosystem of" cluster descriptions, "rich tapestry of connections" graph descriptions. Just say what the metric shows.

## Scope filters

If the wiki gets large (>500 pages), insights mode supports scoping:

- `wiki insights --tag <tag>` — restrict graph analysis to pages with that tag
- `wiki insights --project <name>` — restrict to a project folder
- `wiki insights --recent <days>` — restrict to recently-touched pages

Output report names accordingly: `wiki/meta/insights-<scope>.md`.
