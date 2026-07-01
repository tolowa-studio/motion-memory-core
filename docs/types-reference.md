# Memory types reference

Every memory — file-based or in the MCP server — carries a `type`. The type
tells the agent what the memory is for, and when to apply it.

## `user`

**Role:** Who you are working with.

Role, expertise, preferences, and communication style. How the agent should
calibrate its answers for this person.

- "senior backend engineer, new to React"
- "prefers terse responses"
- "data scientist focused on observability"

## `feedback`

**Role:** How to approach the work.

Corrections and confirmed approaches. The agent should never ask the same
question twice or repeat a mistake once it's been corrected. Save **both**
corrections and confirmations — confirmations are quieter but just as
valuable, and skipping them causes drift away from approaches you've already
validated.

- "no mocks in integration tests — past incident burned us"
- "prefer bundled PRs for refactors"
- "always pass commit messages via HEREDOC"

Structure: the rule, then a **Why:** line, then a **How to apply:** line.

## `project`

**Role:** Context behind the work.

Ongoing goals, decisions, deadlines, and the WHY behind the work — context
that isn't derivable from reading the code or git history.

- "auth rewrite is legal-driven, not tech debt"
- "merge freeze begins 2026-03-05"
- "token routing MVP ships before Q3"

Structure: the fact/decision, then a **Why:** line, then a **How to apply:**
line.

## `reference`

**Role:** Where to look things up.

Pointers to external systems: where bugs are tracked, which Slack channel
owns what, which dashboard to monitor.

- "pipeline bugs → Linear project INGEST"
- "oncall dashboard → grafana.internal/d/api-latency"
- "design tokens → Figma /design-system"

## Linking related memories

Reference other memories with `[[their-name]]` (the file's `name:`
frontmatter, or the memory's slug in the MCP server). A link to a memory that
doesn't exist yet isn't an error — it marks something worth writing later.
