---
name: wiki-export
description: Export the wiki as a navigable graph. Writes graph.json (NetworkX), graph.graphml (Gephi/Cytoscape), cypher.txt (Neo4j), graph.html (self-contained vis.js viewer) to _attachments/wiki-export/. Visibility filter respected — public exports omit visibility/internal and visibility/pii pages by default. Use when user says "export the wiki", "graph viz", "wiki to neo4j", "share the wiki".
---

# wiki-export

Turn the wiki's wikilink graph into navigable artifacts you can open outside Obsidian.

## Outputs

All written to `_attachments/wiki-export/` by default:

| File | Format | Used for |
|---|---|---|
| `graph.json` | NetworkX node-link JSON | Programmatic analysis (Python, JS) |
| `graph.graphml` | GraphML XML | Gephi, yEd, Cytoscape — visual graph editing |
| `cypher.txt` | Cypher CREATE statements | Neo4j import — `LOAD CYPHER` or paste into Neo4j Browser |
| `graph.html` | Self-contained vis.js viewer | Open in any browser — pan/zoom/search, no server needed |

## Workflow

### Step 1: Read filter args

Default filter: `visibility/public` only (omit `visibility/internal` and `visibility/pii`).

Other filter modes:
- `--all` — include all pages regardless of visibility (for personal use only)
- `--internal` — public + internal (omit only pii)
- `--tag <tag>` — restrict to pages with this tag
- `--project <name>` — restrict to a project folder

### Step 2: Build the graph in memory

For each page in scope:

**Node:**
```python
{
  "id": "wiki/concepts/Reciprocal Rank Fusion",
  "label": "Reciprocal Rank Fusion",
  "type": "concept",
  "tags": ["concept", "search"],
  "status": "developing",
  "summary": "...",                       # ≤200 chars from frontmatter
  "confidence": "medium",
  "provenance_extracted": 0.7,
  "provenance_inferred": 0.25,
  "provenance_ambiguous": 0.05,
  "incoming_count": 4,
  "outgoing_count": 7,
  "visibility": "public"
}
```

**Edges:** for each `[[wikilink]]` in body or in `related:`/`sources:` frontmatter:

```python
{
  "source": "wiki/concepts/Hot Cache",
  "target": "wiki/concepts/Compounding Knowledge",
  "type": "wikilink",                     # or "related" or "source"
  "confidence": "EXTRACTED"               # EXTRACTED | INFERRED | AMBIGUOUS
}
```

Edge confidence inferred from context:
- Wikilink in body without `^[inferred]` → EXTRACTED
- Wikilink in body with `^[inferred]` nearby → INFERRED
- Wikilink in `related:` block → EXTRACTED
- Wikilink in `sources:` block → EXTRACTED

### Step 3: Write graph.json

NetworkX node-link format:

```json
{
  "directed": true,
  "multigraph": false,
  "graph": {
    "exported_at": "<ISO>",
    "filter": "<filter description>",
    "node_count": N,
    "edge_count": E,
    "schema_version": "1.0"
  },
  "nodes": [...],
  "links": [...]
}
```

### Step 4: Write graph.graphml

Standard GraphML XML. Include all node attributes as `<data>` keys. Keep edge attributes minimal (source, target, type, confidence) — Gephi/yEd handle this format natively.

### Step 5: Write cypher.txt

```cypher
// Wiki Graph Export — generated <ISO>
// Filter: <filter>
// Nodes: N | Edges: E

// Constraints
CREATE CONSTRAINT IF NOT EXISTS FOR (p:Page) REQUIRE p.id IS UNIQUE;

// Nodes
CREATE (n0:Page {id: 'wiki/concepts/Reciprocal Rank Fusion', label: 'Reciprocal Rank Fusion', type: 'concept', tags: ['concept','search'], summary: '...', confidence: 'medium'});
CREATE (n1:Page {id: 'wiki/concepts/BM25', ...});
...

// Edges
MATCH (a:Page {id: 'wiki/concepts/Hot Cache'}), (b:Page {id: 'wiki/concepts/Compounding Knowledge'})
CREATE (a)-[:LINKS_TO {confidence: 'EXTRACTED'}]->(b);
...
```

### Step 6: Write graph.html (interactive viewer)

Self-contained HTML using `vis.js` (CDN-loaded). The HTML works offline after the first load (vis.js caches), but a fully-vendored option is documented below for air-gapped use.

**Required features:**

- Pan/zoom controls
- Hover tooltips with `summary` field
- Click a node → side panel showing: summary, tags, status, confidence, provenance fractions, list of outgoing/incoming links (each clickable to navigate)
- Color nodes by `type`: concept=blue, entity=green, source=orange, comparison=purple, question=yellow, project=red, decision=teal, journal=gray, reference=lavender, meta=neutral
- Size nodes by incoming-link count (hub pages visibly larger)

**Filter and search controls (top toolbar):**

- **Search box** — filters nodes whose label OR summary contains the query (case-insensitive); non-matches grayed out
- **Tag filter** — multi-select dropdown of all tags in the export; nodes without selected tags grayed out
- **Type filter** — checkboxes for each node type; unchecked types hidden
- **Confidence filter** — slider showing only nodes with confidence ≥ threshold (high|medium|low mapped to 3|2|1)
- **Provenance filter** — slider showing only nodes with `provenance.extracted >= threshold` (0.0–1.0)
- **Edge confidence filter** — toggle: show EXTRACTED only / + INFERRED / + AMBIGUOUS edges
- **Reset filters** button

**Bottom status bar:**
- Shows current visible nodes / total nodes
- Selected node count
- Click count (for engagement tracking, local-only)

**Side panel (when a node is selected):**

```
[X close]
─────────────────────
Reciprocal Rank Fusion      [type: concept]
─────────────────────

Summary
Combine BM25 and vector results via 1/(60+rank) sum.
Mature, high confidence.

Status: developing | Confidence: high
Provenance: 0.85 / 0.13 / 0.02

Tags
type/concept · domain/search · ml

Outgoing (7)
→ [BM25]
→ [Vector Search]
→ [Information Retrieval]
...

Incoming (4)
← [Hybrid Retrieval]
← [Wiki vs RAG]
...

[Open in Obsidian] [Copy wikilink]
```

**Keyboard shortcuts (documented in a /? help overlay):**
- `/` — focus search box
- `Esc` — clear selection / close side panel
- `f` — fit graph to viewport
- `1-9` — toggle visibility of node types
- `←` / `→` — navigate to previously selected node

**Implementation notes:**

- Self-contained HTML: `<script>const graphData = {...};</script>` inlines all data
- vis.js loaded from `cdn.jsdelivr.net` by default; provide an `--vendor` flag to download vis.js into the export so it's air-gapped
- All filtering and search runs client-side — no server, no telemetry
- Total HTML size for a 500-page graph: ~200KB inline data + ~300KB vis.js = ~500KB
- Tested in Chrome, Firefox, Safari (latest)

**The graph.html is what most non-technical users will actually open.** Make this one good.

### Step 7: Update log.md

```markdown
## [YYYY-MM-DD HH:MM] export | filter=<filter>
- nodes: N | edges: E
- output: _attachments/wiki-export/{graph.json, graph.graphml, cypher.txt, graph.html}
- size: X MB
```

### Step 8: Report to user

Print:

```
Exported wiki graph (filter: visibility/public):
  Nodes: 312
  Edges: 1147
  Files written:
    [open] _attachments/wiki-export/graph.html  ← interactive viewer
    _attachments/wiki-export/graph.json
    _attachments/wiki-export/graph.graphml
    _attachments/wiki-export/cypher.txt
```

Surface the `graph.html` first — it's the one most people will use immediately.

---

## Visibility enforcement (security)

Default behavior: pages tagged `visibility/internal` or `visibility/pii` are EXCLUDED from the export entirely (not just hidden — never written to any output file).

Edges to/from excluded nodes are also excluded.

The user must EXPLICITLY pass `--all` or `--internal` to override. The skill should warn loudly if either flag is used:

> WARNING: --all flag set. Export will include `visibility/internal` and `visibility/pii` pages. Use only for personal/local viewing. Do NOT share these files.

---

## What gets excluded always

Even with `--all`:

- `wiki/_raw/` (drafts — not real wiki content)
- `wiki/meta/lint-report-*.md` (transient artifacts)
- Pages with `status: superseded` (unless `--include-superseded` flag passed)

---

## Reading list before exporting

1. `wiki/meta/taxonomy.md` (visibility tag definitions)
2. `wiki/index.md` (page count for sanity checking)
