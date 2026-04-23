---
type: decision
title: "<% tp.file.title %>"
created: <% tp.date.now("YYYY-MM-DD") %>
updated: <% tp.date.now("YYYY-MM-DD") %>
tags: [decision]
status: developing
summary: >-
  [1-2 sentences, ≤200 chars: the decision and why it was made.]
provenance:
  extracted: 0.6
  inferred: 0.35
  ambiguous: 0.05
confidence: medium
related: []
sources: []

# decision-specific
decision_status:    # proposed | accepted | superseded | abandoned
priority: 3         # 1 (high) - 5 (low)
owner: ""
due_date:
context: ""
superseded_by: ""   # set when this decision is replaced
supersedes: ""      # set when this decision replaces an older one
---

# <% tp.file.title %>

> [!decision] Decision
> [The decision in one sentence.]

## Context
[What problem are we solving? What constraints?]

## Options considered
1. **Option A** — [trade-offs]
2. **Option B** — [trade-offs]
3. **Option C** — [trade-offs]

## Decision
[What we chose and why.]

## Consequences
- **Positive**: 
- **Negative**: 
- **Risks**: 

## Sources & references
- [[Source]]

## Related decisions
- [[Decision]]

## Provenance notes
[How firm is this; what's still open.]
