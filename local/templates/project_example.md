---
name: auth-rewrite
description: auth middleware rewrite is compliance-driven, not tech debt
metadata:
  type: project
---

<!--
  PROJECT memories capture ongoing goals, decisions, and deadlines — the WHY
  behind the work that isn't derivable from reading the code. Structure: the
  fact/decision, then Why, then How to apply.
-->

The auth middleware rewrite is driven by a legal/compliance requirement around
session token storage, not a tech-debt cleanup.

**Why:** Legal flagged the old middleware for storing session tokens in a way
that doesn't meet new compliance requirements. Ships before 2026-04-01.

**How to apply:** Scope decisions on this work should favor compliance
correctness over ergonomics or convenience — this isn't optional cleanup.
