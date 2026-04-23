# Sample Meeting Note

*Sample meeting note (your own quick capture, not a transcript) for testing the wiki-ingest raw-mode workflow. Drop into `wiki/_raw/` and say `ingest raw drafts`.*

---

**Date:** 2026-04-15
**Re:** Q2 retrieval architecture

Met with Alex (eng) and Morgan (data) on whether to move from pure vector retrieval to BM25 + vector hybrid.

**Decision: ship hybrid behind a feature flag, full sprint of work, next release.**

The numbers: hybrid is ~8% better on precision-at-1 for short queries (<5 words), neutral for longer ones. Latency goes 80ms → 110ms, still under our 200ms budget. Engineering effort: two days BM25 + half a day fusion + about a week of eval and rollout.

Morgan insisted on a kill switch — feature flag at the request layer so we can fall back instantly if hybrid degrades. Alex agreed and started implementation Monday.

**My open question:** the precision win is on short queries — is that representative of our actual query distribution? I should pull the query log and check before sign-off.

**Follow up:**
- Morgan sends eval methodology Friday
- Alex starts implementation Monday
- I review query distribution next week
