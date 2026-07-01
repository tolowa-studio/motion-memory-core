# Connecting your AI to Motion Memory Core

Every client uses the same two facts:

- **Endpoint:** `https://<your-host>/mcp` (Streamable HTTP)
- **Auth:** `Authorization: Bearer <STASH_TOKEN>`

Legacy clients that only speak SSE use `https://<your-host>/sse` with the same
bearer. Prefer `/mcp` — SSE is deprecated across the MCP ecosystem.

---

## BoltAI (native Mac)

Settings → **Connectors → Add Remote MCP Server**:

- **Name:** `memory`
- **Endpoint URL:** `https://<your-host>/mcp`
- **Auth Type:** Custom headers → `Authorization` = `Bearer <STASH_TOKEN>`

Save & Connect, then enable the server's tools in a chat.

## Cursor / Claude Code / any client with a JSON MCP config

Native Streamable HTTP:

```json
{
  "mcpServers": {
    "memory": {
      "url": "https://<your-host>/mcp",
      "headers": { "Authorization": "Bearer <STASH_TOKEN>" }
    }
  }
}
```

## Claude Desktop (or any stdio-only client)

Claude Desktop currently attaches MCP servers over stdio, so bridge with
`mcp-remote`:

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": [
        "-y", "mcp-remote", "https://<your-host>/mcp",
        "--header", "Authorization:Bearer <STASH_TOKEN>",
        "--transport", "http-only"
      ]
    }
  }
}
```

(Use an absolute path to `npx` if a GUI app can't find it on `PATH`.)

## Verify from the terminal

```bash
curl -s -X POST https://<your-host>/mcp \
  -H "Authorization: Bearer <STASH_TOKEN>" \
  -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"probe","version":"0"}}}'
```

A JSON‑RPC result with `serverInfo` means you're connected. Then any client can
`remember` and `recall` against the same memory.
