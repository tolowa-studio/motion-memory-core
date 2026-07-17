# Motion Memory Core

**Persistent memory for AI agents — two tiers, one system.**

> **Just handed this repo?** → Start with **[`START-HERE.md`](START-HERE.md)** — a two-minute, zero-decisions on-ramp.

Your AI has amnesia. Every new session starts from zero: it doesn't know you
corrected it last week, doesn't know you're under a merge freeze, doesn't know
you hate mocks in tests. Motion Memory Core fixes that with two complementary
tiers you can adopt independently or together.

| | [**Local Memory**](local/) | [**MCP Memory Server**](server/) |
|---|---|---|
| Answers | "What should this agent know in *this repo*?" | "What should *I* remember, everywhere?" |
| Storage | Markdown files, committed to the repo | Postgres, self-hosted, MIT |
| Scope | One repository | Every client, every machine |
| Setup | Copy templates, paste a prompt — no infra | `docker compose up`, one bearer token |
| Works with | Claude Code, Cursor, any file-reading agent | BoltAI, Claude Desktop, Cursor, Claude Code, any [MCP](https://modelcontextprotocol.io) client — over native **Streamable HTTP** |

Read [`docs/architecture.md`](docs/architecture.md) for how the two tiers
relate and when to use each — short version: Local Memory for what's specific
to a codebase and worth a PR review; the MCP server for durable facts about
*you* that should follow you into every repo and every tool.

## Quickstart

**Local Memory** — no infrastructure, start in a repo right now:
```bash
cp -r local/templates .claude/projects/$(pwd | sed 's|/|-|g')/memory
# then paste local/prompts/CLAUDE.md-snippet.md into your CLAUDE.md
```
Full guide: [`local/README.md`](local/README.md).

**MCP Memory Server** — self-hosted, one memory for every AI client:
```bash
cd server && cp .env.example .env   # set STASH_TOKEN + provider key
docker compose up -d
```
Full guide: [`server/README.md`](server/README.md) · Connect any client:
[`server/CONNECTING.md`](server/CONNECTING.md) · One-click deploy:
[`server/deploy/railway.md`](server/deploy/railway.md).

## The 4 memory types

Both tiers share the same typed model — `user`, `feedback`, `project`,
`reference` — so the mental model is identical whether a memory lives in a
markdown file or a database row. Reference:
[`docs/types-reference.md`](docs/types-reference.md) ·
[`docs/when-to-save.md`](docs/when-to-save.md).

## License & credits

- Motion Memory Core (this repo): **MIT** © 2026 Tolowa Studio (see `LICENSE`).
- The MCP server's memory engine is **Stash** (Apache‑2.0) —
  https://github.com/alash3al/stash — used as a dependency, not vendored.
  See `NOTICE`. We've contributed the native Streamable HTTP transport
  upstream: [alash3al/stash#15](https://github.com/alash3al/stash/pull/15).
