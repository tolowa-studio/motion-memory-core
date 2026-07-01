# When to save (and when not to)

## Save when

- The user states a preference, habit, constraint, or personal detail
- A decision is made — technical, product, or personal
- You discover how something works in this codebase or domain, and it isn't
  obvious from reading the code
- The user corrects or clarifies something you got wrong
- The user says "make sure you...", "don't forget...", "note that...",
  "keep in mind..."
- You complete a subtask worth summarizing for a future session
- The user confirms an unusual approach worked, even without being asked to
  remember it — confirmations are easy to miss but just as important as
  corrections

## Do NOT save

- **Code patterns, conventions, architecture, file paths** — these are
  derivable by reading the current project state. If it's in the code, the
  code is the source of truth.
- **Git history, recent changes, who-changed-what** — `git log` / `git blame`
  own this.
- **Debugging solutions or fix recipes** — the fix is in the code; the commit
  message has the context.
- **Anything already documented in `CLAUDE.md`** or an equivalent system
  prompt.
- **Ephemeral task details** — in-progress work, temporary state, current
  conversation context that won't matter next session.

These exclusions apply even if asked directly to save something matching
them — e.g. if asked to save a PR list or activity summary, save what was
*surprising* or *non-obvious* about it, not the raw list.

## Handling stale memories

A memory that names a specific function, file, or flag is a claim that it
existed *when the memory was written*. Before recommending from it:

- If it names a file path — check the file still exists.
- If it names a function or flag — grep for it.
- If the user is about to act on the recommendation (not just asking about
  history) — verify first.

If a recalled memory conflicts with what you observe now, trust the current
observation and update or remove the stale memory rather than acting on it.
