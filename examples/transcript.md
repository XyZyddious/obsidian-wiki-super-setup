# Sample Meeting Transcript

*Sample transcript for testing the wiki-ingest workflow. Drop into `.raw/` and say `ingest examples/transcript.md`.*

---

**Date:** 2026-04-15 (sample)
**Attendees:** Alex (engineering lead), Jordan (PM), Morgan (data)

---

**Alex:** OK so the question on the table is whether we move to BM25 plus vector hybrid retrieval or stick with pure vector.

**Jordan:** Why are we even revisiting? I thought vector won the bake-off.

**Alex:** Vector won on recall but precision dropped on short queries. The hybrid would help with the keyword-heavy stuff.

**Morgan:** I ran the numbers last week. Hybrid is roughly 8% better on the precision-at-1 metric for queries under five words. About the same for longer queries.

**Jordan:** And cost?

**Morgan:** Hybrid adds about 30 milliseconds per query. We're at 80 ms now, so 110 ms with the change.

**Alex:** Still under our 200 ms budget. I think we should do it.

**Jordan:** What about the engineering effort?

**Alex:** Two days for the BM25 implementation, half a day for the fusion logic, maybe a week for the eval and rollout. Call it a sprint.

**Morgan:** I'd want to add a kill switch though. If hybrid degrades for any reason, we should be able to fall back to pure vector instantly.

**Alex:** Agreed. Feature flag at the request layer.

**Jordan:** OK. Let's call it. We're going hybrid, behind a flag, full sprint of work, ship next release. I'll write it up.

**Morgan:** Action items for me — share the eval methodology with the broader team. I'll have it Friday.

**Alex:** I'll start the implementation Monday.

**Jordan:** Decision logged. Let's move on.
