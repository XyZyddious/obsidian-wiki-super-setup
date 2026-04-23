# The Compounding Knowledge Pattern

*Sample article for testing the wiki-ingest workflow. Drop into `.raw/` and say `ingest examples/article.md`.*

---

When most people use an LLM, they treat each conversation as ephemeral. You ask a question, get an answer, and the answer disappears into chat history. The next time you have a similar question, you ask again. The model re-derives the answer from scratch. Knowledge does not accumulate.

The LLM Wiki pattern, named by Andrej Karpathy in 2024, proposes a different shape. The conversation is the interface, not the product. The product is a wiki — a structured Markdown vault that the LLM maintains. Every source you add gets processed into linked entity and concept pages. Every question you ask draws on everything that has been read. Cross-references are pre-built. Contradictions get flagged. Synthesis already reflects the cumulative reading.

The pattern has three layers. Raw sources live in an immutable directory; the LLM reads them but never modifies. The wiki itself is LLM-owned — the LLM creates pages, updates them when new sources arrive, maintains cross-references. The schema is the configuration document (typically `CLAUDE.md` or `AGENTS.md`) that defines conventions and workflows.

Karpathy's gist sketched the pattern but stopped short of an implementation. Several follow-up projects have added concrete machinery: confidence scoring, supersession workflows, retrieval-primitives ladders, scored cross-linking, tag taxonomies, graph-aware insights modes. The pattern is most useful when treated as compounding interest. Most production wikis exceed 200 pages within six months of active use.

There are real risks. Source documents can contain prompt-injection attempts ("ignore your instructions and..."), so any ingest workflow needs a content-trust boundary that treats sources as data, not commands. Synthesis pages drift toward speculation if not actively sourced. AI-written prose has stylistic tells (significance inflation, em-dash overuse, "not just X but Y") that erode trust over time without active counter-pressure.

The pattern's core insight stands regardless: a wiki is a persistent, compounding artifact, and treating it as such changes how an LLM relates to the knowledge it processes. Stop re-deriving. Start compiling.
