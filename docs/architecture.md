# Architecture — two tiers, one system

Motion Memory Core is two complementary memory tiers. Use either alone, or
both together — they don't conflict, because they answer different questions.

| | [Local Memory](../local/) | [MCP Memory Server](../server/) |
|---|---|---|
| **Answers** | "What should this agent know while working in *this repo*?" | "What should *I* remember, everywhere, forever?" |
| **Storage** | Markdown files, committed to the repo | Postgres + pgvector, self-hosted |
| **Scope** | One repo | Every client, every machine |
| **Setup** | Copy templates, paste a prompt | `docker compose up` or one-click deploy |
| **Access** | The agent's own file reads/writes | MCP tools over Streamable HTTP (`recall`, `remember`, ...) |
| **Reviewable** | Yes — it's a PR diff | No — it's a database |
| **Infra required** | None | Postgres + a host |

## Why both

A repo-local `CLAUDE.md` correction ("don't mock the database in this repo's
tests") belongs in **Local Memory** — it's specific to this codebase, and a
teammate reviewing the PR that added it can see exactly what changed and why.

A standing fact about *you* ("I prefer terse responses," "I'm a senior backend
engineer, new to React") belongs in the **MCP Memory Server** — it should
follow you into every repo, every machine, every AI client, not just the one
you happened to be in when you said it.

## How they compose

```
                    ┌─────────────────────────┐
Your AI clients ───▶│   MCP Memory Server      │  cross-repo, cross-client,
(BoltAI, Cursor,     │   (Postgres, /mcp)       │  durable — "who you are"
 Claude Code, ...)   └─────────────────────────┘
        │
        │  reads CLAUDE.md at session start
        ▼
┌─────────────────────────┐
│   Local Memory           │  per-repo, git-versioned,
│   (.claude/.../memory/)  │  reviewable — "what this repo needs"
└─────────────────────────┘
```

Both tiers use the same **4 memory types** — `user`, `feedback`, `project`,
`reference` — so the mental model is identical whether a fact lives in a
markdown file or a database row. See
[`types-reference.md`](types-reference.md) and
[`when-to-save.md`](when-to-save.md).

## MCP server transport

The server tier speaks MCP over **Streamable HTTP** (the current spec
transport) at `/mcp`, and legacy **SSE** at `/sse` for older clients. One
bearer token, one gateway, both transports — see
[`../server/README.md`](../server/README.md) and
[`../server/CONNECTING.md`](../server/CONNECTING.md) for per-client setup.
