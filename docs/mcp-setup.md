# MCP Setup (Optional)

The Model Context Protocol (MCP) lets external Claude clients (Claude Desktop, IDEs, etc.) read and write the vault directly without going through Claude Code. This is optional — the vault works fully without any MCP setup.

**When you'd want this:**

- You use Claude Desktop and want the wiki accessible there
- You want to query the wiki from another Claude Code project without copying paths
- You want a non-Claude tool (Cursor, Windsurf, custom client) to access the vault via MCP

**When you don't need this:**

- You only use Claude Code in the vault directory itself — no MCP needed
- You don't want any external tool reading/writing the vault — skip this entirely

---

## Two main options

### Option A: Local REST API + mcp-obsidian

Install the [Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) Obsidian plugin, then connect via the [mcp-obsidian](https://github.com/MarkusPfundstein/mcp-obsidian) MCP server.

**Pros:** uses Obsidian's APIs (respects Templater, plugins, etc.). Read AND write supported.

**Cons:** Obsidian must be running for the API to respond.

#### Setup

1. In Obsidian: Settings → Community Plugins → Browse → install "Local REST API"
2. Settings → Local REST API → enable, copy the API key
3. In Claude Code (or your MCP client config):

```bash
claude mcp add-json obsidian-vault '{
  "command": "uvx",
  "args": ["mcp-obsidian"],
  "env": {
    "OBSIDIAN_API_KEY": "<paste-key-here>",
    "OBSIDIAN_HOST": "127.0.0.1",
    "OBSIDIAN_PORT": "27124"
  }
}'
```

4. Verify: `claude mcp list` should show `obsidian-vault`. Test with: "Claude, read wiki/index.md via the obsidian MCP"

### Option B: Filesystem MCP (no Obsidian plugin)

Install the [@bitbonsai/mcpvault](https://github.com/bitbonsai/mcpvault) MCP server, which reads the vault directly from the filesystem.

**Pros:** Obsidian doesn't need to be running. Simpler setup.

**Cons:** doesn't respect Obsidian-runtime features (Templater, Dataview queries don't render). Read-only by default.

#### Setup

```bash
claude mcp add-json obsidian-vault '{
  "command": "npx",
  "args": ["-y", "@bitbonsai/mcpvault@latest", "/absolute/path/to/your/vault"]
}'
```

Replace `/absolute/path/to/your/vault` with the real path.

Verify: `claude mcp list`. Test with: "Claude, list pages in wiki/concepts/ via mcpvault"

---

## Cross-project access via MCP

Once an MCP server is configured, you can read/write the vault from any other Claude Code project, not just the vault directory itself.

In another project's `CLAUDE.md`:

```markdown
## Wiki Knowledge Base
This project has access to my obsidian-wiki super setup vault via MCP (server name: obsidian-vault).

Read in this order, only as needed:
1. wiki/hot.md (recent context, ~500 words)
2. wiki/index.md (master catalog)
3. wiki/<category>/_index.md (sub-index)
4. Individual wiki pages

Don't read the wiki for general coding questions or things already in this project.
```

Then in chat: "Claude, what does the vault say about hybrid retrieval?" — Claude routes through MCP automatically.

---

## Claude Desktop integration

To make the vault accessible in Claude Desktop:

1. Install one of the MCP servers above (REST API or mcpvault)
2. Edit `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) or `%APPDATA%\Claude\claude_desktop_config.json` (Windows):

```json
{
  "mcpServers": {
    "obsidian-vault": {
      "command": "uvx",
      "args": ["mcp-obsidian"],
      "env": {
        "OBSIDIAN_API_KEY": "<paste-key>",
        "OBSIDIAN_HOST": "127.0.0.1",
        "OBSIDIAN_PORT": "27124"
      }
    }
  }
}
```

3. Restart Claude Desktop. Look for the 🔌 MCP indicator in the chat input.
4. Test: "What's in my wiki/index.md?"

---

## Security considerations

- **The REST API listens on localhost only** by default. Don't change this — exposing it to the network would let anything on your LAN read your vault.
- **The API key is sensitive.** Store it in `~/.config/` or your OS keychain, not in plaintext config files in the vault.
- **MCP servers run with your full filesystem permissions.** A misconfigured MCP server could potentially read files outside the vault. Pin to a specific vault path (Option B) when possible.
- **For published vaults**, NEVER include MCP credentials. The `.gitignore` should exclude any `mcp-config.json` or similar.

---

## Troubleshooting

**"obsidian-vault MCP not responding"**
- For Option A: is Obsidian actually running? Open it.
- Check `claude mcp logs obsidian-vault` for connection errors.
- Verify the port (default 27124) isn't blocked by firewall.

**"permission denied" reading vault files via mcpvault**
- Check the path you passed is correct and readable
- macOS: System Settings → Privacy → Full Disk Access for the terminal/Claude Code

**"the MCP wrote to the vault but it didn't update Obsidian"**
- Obsidian watches the filesystem and should reload, but sometimes needs a manual: View → Force Reload
- File-watcher delays are normal (~1 second)

---

## Note on dependencies

This is **explicitly optional** infrastructure. The vault's 14 wiki skills work completely without MCP — they read and write the vault directly via Claude Code's filesystem tools. Set up MCP only if you have a specific use case for cross-tool access.
