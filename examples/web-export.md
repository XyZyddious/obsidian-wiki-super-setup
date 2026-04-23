---
source_url: https://example.com/sample-article
source_title: "Provenance in Knowledge Bases"
fetched_at: 2026-04-15T09:00:00Z
fetch_method: defuddle
---

# Provenance in Knowledge Bases

*Sample web export (after defuddle clean) for testing URL ingestion. Drop into `.raw/` and say `ingest examples/web-export.md`. The frontmatter at the top tells wiki-ingest where it came from.*

---

A knowledge base loses trust the moment its readers cannot tell a primary observation from a secondary inference. Most wikis fail at this quietly. Pages accumulate confident-sounding claims with no internal distinction between what the source actually said and what the editor extrapolated.

Three buckets matter. **Extracted** claims come directly from a source — you can point at the sentence. **Inferred** claims are your synthesis or extrapolation across multiple sources. **Ambiguous** claims are where sources disagree or you are uncertain. Conflating the three is the most common quality failure in LLM-generated wikis.

Marking provenance inline costs almost nothing per claim and pays compounding returns. A reader scanning a page can immediately see how speculative the page is. A future editor knows what needs re-sourcing. An audit can recompute the page's reliability automatically. None of this is possible if every claim looks equally authoritative.

The simplest implementation uses two inline markers — `^[inferred]` after extrapolated claims, `^[ambiguous]` after contested ones — plus a frontmatter block summarizing the page-level distribution. Pages with high inference fractions get flagged for review. Pages with high ambiguity get flagged for re-sourcing. Hub pages with significant inference content get flagged urgently because their uncertainty propagates.

The tradeoff is small editing overhead in exchange for systematic trust. For a knowledge base that compounds over time, that's almost always worth it.

---

*Source: example.com (synthetic for testing)*
