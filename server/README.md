# MCP Memory Server (Tier 2)

**An open, self‑hostable memory layer for any AI agent. One memory, every client.**

Your AI has amnesia. This fixes it — and it does it for *every* tool you use,
not one. Connect BoltAI, Claude Desktop, Cursor, Claude Code, or anything that
speaks [MCP](https://modelcontextprotocol.io) to a single memory you own and
host. Remember once; recall everywhere.

For memory scoped to a single repo instead — cheap, git‑versioned, no
infrastructure — see [Local Memory](../local/) (Tier 1). The two tiers are
complementary; see [`../docs/architecture.md`](../docs/architecture.md).

> This layer is the deploy + gateway + transport + integration code. The memory
> engine is the excellent [Stash](https://github.com/alash3al/stash) project
> (Apache‑2.0). This layer adds native Streamable HTTP, a bearer‑auth gateway,
> one‑click deploy, and multi‑client guides — all MIT. See `../NOTICE`.

## Why

- **One memory across every client.** MCP is the common language; this server
  speaks it over the modern **Streamable HTTP** transport (and legacy SSE for
  older clients), so the same memory serves all of them.
- **You own it.** Self‑host on your own infra. Your episodes, facts, and context
  live in *your* Postgres. One bearer token guards the door.
- **Real memory, not a note file.** Powered by Stash's consolidation pipeline:
  raw episodes → structured facts → relationships → confidence‑decayed beliefs.

## Architecture

```
Your AI clients                         one bearer token
  BoltAI · Claude Desktop · Cursor · Claude Code · any MCP client
        │  MCP over Streamable HTTP  (legacy SSE also served)
        ▼
  Gateway  (Caddy)  — bearer auth · transparent reverse proxy
        ▼
  Stash engine (Go) — serves /mcp (Streamable HTTP) + /sse · MCP tools
        ▼
  Postgres + pgvector — episodes · facts · context (your data)
```

## Quickstart (self‑host, local)

```bash
git clone https://github.com/tolowa-studio/motion-memory-core.git
cd motion-memory-core/server
cp .env.example .env          # then set STASH_TOKEN (openssl rand -hex 32) + provider key
docker compose up -d
curl -s -X POST localhost:8080/mcp \
  -H "Authorization: Bearer $STASH_TOKEN" \
  -H 'Content-Type: application/json' -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"probe","version":"0"}}}'
```

For a hosted deploy, see [`deploy/railway.md`](deploy/railway.md) (one‑click).

## Connect your AI

Point any MCP client at your server URL with the bearer token:

- **Endpoint:** `https://<your-host>/mcp`  (Streamable HTTP)
- **Auth header:** `Authorization: Bearer <STASH_TOKEN>`

Per‑client, copy‑paste setup: [`CONNECTING.md`](CONNECTING.md).

## Security

- The gateway rejects any request without the exact bearer token (401).
- Nothing here contains secrets — tokens are per‑deploy environment variables.
- Self‑hosting means the memory data and the provider key never leave your infra.

## License & credits

- This layer: **MIT** © 2026 Tolowa Studio (see `../LICENSE`).
- Memory engine: **Stash** (Apache‑2.0) — https://github.com/alash3al/stash (see `../NOTICE`).
