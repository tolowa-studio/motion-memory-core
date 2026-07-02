<!-- Draft only — not posted anywhere. Review and edit before publishing. -->

# Announcement draft

**Short version (X/LinkedIn):**

> Your AI has amnesia. Every new chat starts from zero.
>
> We built Motion Memory Core — an open-source, self-hostable memory layer
> for AI agents. One memory, every client: BoltAI, Claude Desktop, Cursor,
> Claude Code, anything that speaks MCP.
>
> MIT licensed. Your data, your infra. Deploy in one command.
>
> github.com/tolowa-studio/motion-memory-core

---

**Longer version (blog / LinkedIn article):**

## We open-sourced our memory layer

Every AI coding session starts from zero. It doesn't remember you corrected
it last week. It doesn't know you're under a merge freeze. It doesn't know
you hate mocks in tests. Close the tab, and it's gone.

We built **Motion Memory Core** to fix that — for real, not as a demo.

It's two tiers:

- **Local Memory** — file-based, git-versioned, scoped to a repo. No
  infrastructure. Copy four templates, paste a prompt.
- **MCP Memory Server** — a self-hosted memory that follows *you*, not one
  repo. Connect BoltAI, Claude Desktop, Cursor, Claude Code — anything that
  speaks [MCP](https://modelcontextprotocol.io) — to one memory over the
  modern Streamable HTTP transport.

It's MIT licensed. The memory engine underneath is the excellent
[Stash](https://github.com/alash3al/stash) project — we're not reinventing
memory, we're making it reachable from every client you actually use, and
we've [contributed our transport patch back upstream](https://github.com/alash3al/stash/pull/15).

We didn't just write docs and call it done. Everything in the repo has been
run for real: a from-scratch `docker compose up` boots the whole stack and
passes a live MCP handshake. Backups are real `pg_dump` jobs that verify
their own upload. The gateway rate-limits by IP. Health checks do an actual
database check, not a process-up ping.

**Try it:**
```bash
git clone https://github.com/tolowa-studio/motion-memory-core.git
cd motion-memory-core/server && cp .env.example .env
docker compose up -d
```

github.com/tolowa-studio/motion-memory-core

---

**Before posting anywhere, check:**
- [ ] Merge & deploy [tolowa-studio/tolowa-studio#59](https://github.com/tolowa-studio/tolowa-studio/pull/59) so tolowastudio.com/memory reflects this
- [ ] Publish the Railway template (see `server/deploy/create-template.md`) and drop the badge into the README
- [ ] Decide whether to link the upstream PR status (still open, unmerged)
