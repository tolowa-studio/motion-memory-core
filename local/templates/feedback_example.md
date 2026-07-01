---
name: no-db-mocks
description: integration tests must hit a real database — not mocks
metadata:
  type: feedback
---

<!--
  FEEDBACK memories capture corrections AND confirmed approaches — the agent
  should never ask the same question twice or repeat a mistake once it's been
  corrected. Structure: the rule, then Why, then How to apply.
-->

Never mock the database in integration tests.

**Why:** A prior incident — mocked tests passed but the production migration
failed. The mock/prod divergence masked a broken migration and caused an
outage.

**How to apply:** Any time tests are written for database operations, use a
real test database. No exceptions unless the user explicitly requests one.

Related: [[test-strategy]], [[deploy-checklist]]
