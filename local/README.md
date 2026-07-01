# Local Memory (Tier 1)

File-based, git-versioned project memory for any agent that reads a system
prompt file (Claude Code's `CLAUDE.md`, Cursor's `.cursorrules`, etc.). No
infrastructure, no server, no signup — just markdown in your repo.

Best for: **what this agent should know while working in this codebase.**
Cheap, reviewable in a PR diff, and travels with the repo it describes.

For memory that should follow *you* across every repo, machine, and AI
client — not just one codebase — see the [MCP memory server](../server/)
(Tier 2).

## Setup (4 steps)

1. **Create the memory directory:**
   ```bash
   mkdir -p .claude/projects/$(pwd | sed 's|/|-|g')/memory
   ```
   Or let the agent create it — most agents will initialize this
   automatically once the prompt below is in place.

2. **Copy the index template:**
   ```bash
   cp templates/MEMORY.md .claude/projects/{path}/memory/MEMORY.md
   ```
   The index is loaded every session. Keep each entry to one line
   (~150 chars). Never write memory content here — only pointers.

3. **Write your first memory** using one of the typed templates in
   [`templates/`](templates/) — `user_profile.md`, `feedback_example.md`,
   `project_example.md`, `reference_example.md`.

4. **Add the memory prompt** from
   [`prompts/CLAUDE.md-snippet.md`](prompts/CLAUDE.md-snippet.md) to your
   `CLAUDE.md`. This tells the agent to read and write memory.

## The 4 memory types

| Type | Role | Examples |
|---|---|---|
| `user` | Who you're working with | role, expertise, communication preferences |
| `feedback` | How to approach the work | corrections, confirmed approaches |
| `project` | Context behind the work | decisions, deadlines, the WHY |
| `reference` | Where to look things up | external systems, dashboards, trackers |

Full type reference: [`../docs/types-reference.md`](../docs/types-reference.md).
When to save (and when not to): [`../docs/when-to-save.md`](../docs/when-to-save.md).
