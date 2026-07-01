---
name: bug-tracking
description: pipeline bugs are tracked in Linear project INGEST
metadata:
  type: reference
---

<!--
  REFERENCE memories are pointers to external systems: where bugs are
  tracked, which dashboard to check, which Slack channel owns what. Keep
  these current — a stale reference is worse than none.
-->

Pipeline bugs are tracked in the Linear project **INGEST**, not the general
backlog.

Related dashboards: oncall latency at `grafana.internal/d/api-latency` — check
this before editing request-path code, since that's what pages someone.
