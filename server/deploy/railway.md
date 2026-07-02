# Deploy Motion Memory Core on Railway

MMC runs as four services in one Railway project:

| Service | What it is | Source |
|---|---|---|
| `postgres` | memory store (pgvector) | Railway Postgres plugin (add pgvector) |
| `stash` | memory engine | built from `deploy/Dockerfile.stash` |
| `gateway` | bearer-auth, rate-limited proxy (public) | built from `gateway/Dockerfile` + `gateway/Caddyfile` |
| `pg-backup` | scheduled Postgres backup to S3-compatible storage | built from `backup/Dockerfile` (see [`../backup/README.md`](../backup/README.md)) |

## Steps

1. **Create the project** and add a **Postgres** database (enable the `vector`
   extension).
2. **stash service** — deploy from this repo using `deploy/Dockerfile.stash`.
   Stash's config loader requires ALL of the following — there are no
   built-in defaults (confirmed by actually booting it with a partial set):
   - `STASH_POSTGRES_DSN` → the Postgres connection string. If Railway's
     Postgres plugin doesn't expose a `DATABASE_URL`-style variable directly
     on itself, construct it:
     `postgres://<user>:<password>@<postgres-service>.railway.internal:5432/<db>?sslmode=disable`
   - `STASH_OPENAI_API_KEY`, `STASH_OPENAI_BASE_URL`
   - `STASH_EMBEDDING_MODEL` (e.g. `openai/text-embedding-3-small`)
   - `STASH_REASONER_MODEL` (e.g. `openrouter/free`)
   - `STASH_VECTOR_DIM` (e.g. `1536`, must match your embedding model)
   - `STASH_MAX_RESULT_SIZE` (e.g. `10000`)
   - `STASH_CONTEXT_TTL` (e.g. `1h`)
   - `STASH_HTTP_ADDR` → `:8080` (or `:$PORT`)
   - `STASH_LOG_LEVEL` (e.g. `info`), `STASH_LOG_FORMAT` (e.g. `json`)

   The engine listens on one port (`$PORT`, default 8080) serving `/mcp`
   (Streamable HTTP), `/sse` + `/message` (legacy SSE), and `/healthz` (real
   DB-backed health check — not a bare process-up ping).
3. **gateway service** — deploy from `gateway/Dockerfile` (builds Caddy with
   the `caddy-ratelimit` plugin; the Caddyfile is baked in at build time). Set:
   - `STASH_TOKEN` → `openssl rand -hex 32`
   - `STASH_UPSTREAM` → `stash.railway.internal:8080`
   Generate a public domain for this service — that host + `/mcp` is your
   endpoint. Rate limiting (120 req/min per IP) and bearer auth are both
   already in the Caddyfile.
4. **pg-backup service** — deploy from `backup/Dockerfile`. Set `DATABASE_URL`
   (same value as step 2), `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` (R2 or
   any S3-compatible store), `S3_BUCKET`, `S3_ENDPOINT_URL`. Set a cron
   schedule (dashboard, or via the API with `cronSchedule: "0 3 * * *"` and
   `restartPolicyType: "NEVER"`). Full details: [`../backup/README.md`](../backup/README.md).
5. **Wire the healthcheck** on the `stash` service: `healthcheckPath: /healthz`,
   a reasonable timeout (30s), and `restartPolicyType: ON_FAILURE` so a real
   database outage triggers an automatic restart instead of silently serving
   errors.
6. **Connect clients** with `Authorization: Bearer <STASH_TOKEN>` — see
   [`../CONNECTING.md`](../CONNECTING.md).

## Hardening checklist (all done above, not optional extras)

- ✅ **Postgres backups** — scheduled `pg_dump` → S3-compatible storage,
  verified upload, auto-pruned. Memory is irreplaceable.
- ✅ **Fail-closed healthcheck** — `/healthz` does a real database check, not
  a process-up ping. Wired to Railway's restart policy.
- ✅ **Rate limiting** — `caddy-ratelimit`, keyed by client IP, applied before
  auth so it also throttles brute-force token guessing.

## One-click deploy

A "Deploy on Railway" button requires publishing a Railway Template, which is
a dashboard-only action (no CLI/API path exists) — see
[`create-template.md`](create-template.md) for the exact steps to publish one
from this hardened setup.
