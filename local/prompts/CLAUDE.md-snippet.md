Paste this into your project's `CLAUDE.md` (or equivalent system prompt) to wire
in Local Memory.

```markdown
# Memory

You have a persistent, file-based memory system at
`.claude/projects/{path}/memory/`. Write to it directly with the Write tool —
do not check for its existence first.

Build this memory over time so future conversations have a complete picture
of who the user is, how they like to collaborate, what behaviors to avoid or
repeat, and the context behind the work they give you.

## When to save memories

- **User** — any time you learn about their role, expertise, or
  communication preferences
- **Feedback** — when they correct your approach OR confirm an unusual
  choice worked (save BOTH)
- **Project** — when you learn WHY something is being built, by when, or by
  whom
- **Reference** — when you learn where to find things in external systems

## Memory file format

\`\`\`markdown
---
name: short-kebab-slug
description: one-line summary (shown in MEMORY.md index)
metadata:
  type: user | feedback | project | reference
---

Body content here. For feedback/project types, include a **Why:** line and a
**How to apply:** line. Link related memories with [[their-name]].
\`\`\`

## The index

After writing a memory, add a one-line pointer to MEMORY.md:
`- [Title](file.md) — one-line hook (~150 chars)`

MEMORY.md is always loaded. Keep it under 200 lines. Never write memory
content directly into MEMORY.md.
```
