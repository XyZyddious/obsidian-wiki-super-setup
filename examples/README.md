# Examples

Sample sources for testing the `wiki-ingest` workflow without finding your own content first.

## Files

| File | Use as | Drop into | Trigger |
|---|---|---|---|
| `article.md` | Web/blog article | `.raw/` | `ingest examples/article.md` |
| `transcript.md` | Meeting transcript | `.raw/` | `ingest examples/transcript.md` |
| `meeting-note.md` | Quick draft note | `wiki/_raw/` | `ingest raw drafts` |
| `web-export.md` | Defuddle web export with source frontmatter | `.raw/` | `ingest examples/web-export.md` |

## What to expect

Each ingest will:

1. Read the file under the content-trust boundary
2. Extract entities, concepts, claims, open questions
3. Pause to ask you about any new tag candidates (via `AskUserQuestion`)
4. Create 8-15 wiki pages with universal frontmatter
5. Run `cross-linker` automatically on the new pages
6. Update `wiki/index.md` and `wiki/log.md`

After running an ingest, try:

- `what do you know about hybrid retrieval?` (uses content from `transcript.md`)
- `wiki status` to see what got created
- `wiki insights` to see hub pages emerging
- `lint the wiki` to verify quality

## Cleaning up

To remove the ingested test content (keep the example sources):

```bash
# Remove the source pages this ingest created
rm wiki/sources/article.md wiki/sources/transcript.md wiki/sources/meeting-note.md wiki/sources/web-export.md 2>/dev/null

# Remove from manifest
# (or just run `wiki-rebuild full` to start fresh — it'll re-ingest .raw/ from scratch)
```

Or just run `wiki-rebuild` which archives the current state and rebuilds from `.raw/`.

## Note

These are synthetic examples designed to exercise the workflow. The content is intentionally generic so you can see how Claude classifies, tags, and links it. After you've tested, delete these files and start with your own real content.
