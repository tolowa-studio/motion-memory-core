# Deploy Motion Memory Core on Railway

MMC runs as three services in one Railway project:

| Service | What it is | Source |
|---|---|---|
| `postgres` | memory store (pgvector) | Railway Postgres plugin (add pgvector) |
| `stash` | memory engine | built from `deploy/Dockerfile.stash` |
| `gateway` | bearer-auth proxy (public) | `caddy:2` + `gateway/Caddyfile` |

## Steps

1. **Create the project** and add a **Postgres** database (enable the `vector`
   extension).
2. **stash service** — deploy from this repo using `deploy/Dockerfile.stash`.
   Set variables:
   - `DATABASE_URL` → reference the Postgres service's URL
   - `STASH_OPENAI_API_KEY`, `STASH_OPENAI_BASE_URL`
   The engine listens on `:8080` (`/mcp` + `/sse`) and `:9090` (health/metrics).
3. **gateway service** — deploy `caddy:2` with `gateway/Caddyfile`. Set:
   - `STASH_TOKEN` → `openssl rand -hex 32`
   - `STASH_UPSTREAM` → `stash.railway.internal:8080`
   Generate a public domain for this service — that host + `/mcp` is your
   endpoint.
4. **Connect clients** with `Authorization: Bearer <STASH_TOKEN>` — see
   [`../CONNECTING.md`](../CONNECTING.md).

## Hardening (recommended for real use)

- Turn on **Postgres backups** — memory is irreplaceable.
- Add a **healthcheck** on the `stash` service.
- Rate‑limit at the gateway (Caddy `rate_limit`).

> A one‑click **Deploy on Railway** template button will be added here once the
> template is published.
