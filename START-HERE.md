# Start Here

You were handed this because it fixes the most annoying thing about AI
assistants: **they forget everything between sessions.** Every morning your AI
has amnesia — you re-explain who you are, what you're building, and how you like
to work. This gives your AI a real memory that *you own*.

There are two paths. **Do Path 1 first — it takes two minutes and costs
nothing.** Add Path 2 when you want your memory to follow you across every tool.

---

## Path 1 — Memory for one project (2 minutes, free, no accounts)

**Best for:** "I want Claude Code / Cursor to remember how *this* codebase
works — and stop re-learning it every session."

From inside the repo you want to give a memory, run:

```bash
# 1. make the memory folder for this repo
mkdir -p .claude/projects/$(pwd | sed 's|/|-|g')/memory

# 2. copy the starter templates in (adjust the path to wherever you cloned this)
cp -r ~/motion-memory-core/local/templates/* \
      .claude/projects/$(pwd | sed 's|/|-|g')/memory/
```

Then open [`local/prompts/CLAUDE.md-snippet.md`](local/prompts/CLAUDE.md-snippet.md),
copy it, and paste it into your repo's `CLAUDE.md` (create the file if it
doesn't exist). That snippet is what tells the agent to read and write memory.

**Done.** Your agent now remembers decisions and preferences for this repo — and
because it's just markdown committed to the repo, you can *see* every memory in
your git diffs and review them like any other change. Full guide:
[`local/README.md`](local/README.md).

---

## Path 2 — Memory that follows you everywhere (~15 min, one API key)

**Best for:** "I want *one* memory across every tool and every project —
BoltAI, Cursor, Claude Desktop, Claude Code — that knows *me*, not just one repo."

**You'll need one thing:** an **OpenAI** (or any OpenAI-compatible, e.g.
OpenRouter) **API key**. The memory uses it to embed and organize what it
remembers. Cost is pennies — it only runs when you save or recall.

**Easiest — hosted on Railway (no Docker):**
Follow [`server/deploy/railway.md`](server/deploy/railway.md). ~15 minutes,
four services, a public URL at the end. That URL + `/mcp` is your memory.

**Or local — with Docker:**
```bash
cd server
cp .env.example .env          # fill in 3 values: STASH_TOKEN, POSTGRES_PASSWORD, your API key
docker compose up -d
```

Then point your AI tools at it — copy-paste setup for each client (BoltAI,
Cursor, Claude Code, Claude Desktop) is in
[`server/CONNECTING.md`](server/CONNECTING.md).

---

## Which do I use?

| You want… | Use |
|---|---|
| Your coding agent to stop re-learning *this* repo | **Path 1** |
| Your assistant to know *you* across every tool and machine | **Path 2** |
| To be serious about this | **Both** — Path 1 per repo, Path 2 for the durable facts about you |

---

## What's under the hood (30 seconds)

One MCP server talking to one Postgres + pgvector database. That's the whole
thing — no second engine, no lock-in. The memory engine is the excellent
open-source [**Stash**](https://github.com/alash3al/stash) (Apache-2.0); this
repo adds the deploy glue, a bearer-auth gateway, native Streamable-HTTP
transport, and the guides — all MIT.

The one idea most people miss: **an index is not a database.** Memory stores
*distilled conclusions* that point to where the full detail lives — it doesn't
try to hold everything. That's what keeps it fast and clean as it grows.

Questions? Ask the person who gave this to you, or open an issue.
