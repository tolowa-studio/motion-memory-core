# Backups & restore

Memory is irreplaceable — this is a real `pg_dump` → gzip → S3-compatible
storage job, not a placeholder. Fail-closed: a dump under 1KB (almost
certainly broken) refuses to upload rather than silently store a bad backup.

## What it does

1. `pg_dump` the whole database (schema + data), gzip it.
2. Refuse to proceed if the dump is suspiciously small (<1KB).
3. Upload to `s3://$S3_BUCKET/$S3_PREFIX/<timestamp>.sql.gz`.
4. **Verify the upload** with a HEAD request — a backup that "succeeded" but
   isn't actually retrievable is worse than no backup.
5. Prune backups older than `RETENTION_DAYS` (default 30).

## Deploy (Railway)

```bash
cd server/backup
railway add --service pg-backup
railway variables --service pg-backup \
  --set 'DATABASE_URL=${{<your-postgres-service>.DATABASE_URL}}' \
  --set "AWS_ACCESS_KEY_ID=<r2-access-key-id>" \
  --set "AWS_SECRET_ACCESS_KEY=<r2-secret-access-key>" \
  --set "S3_BUCKET=<your-bucket>" \
  --set "S3_ENDPOINT_URL=https://<account-id>.r2.cloudflarestorage.com" \
  --set "S3_PREFIX=postgres" \
  --set "RETENTION_DAYS=30"
railway up --service pg-backup
```

Then set a cron schedule on the service (dashboard, or via the API —
`serviceInstanceUpdate` with `cronSchedule: "0 3 * * *"` and
`restartPolicyType: "NEVER"` so it runs once per trigger instead of looping).

> **Getting `DATABASE_URL`:** if your Postgres service doesn't expose a
> `DATABASE_URL` variable directly, check what your main app service uses to
> connect (e.g. `STASH_POSTGRES_DSN`) and reference that same variable
> expression — Railway's Postgres plugin doesn't always define `DATABASE_URL`
> on itself.

### R2 credentials (Cloudflare)

R2's S3-compatible API needs an Access Key ID / Secret Access Key pair, not a
plain API token:

```bash
# 1. Create a scoped API token (R2 Storage Write only) via the Cloudflare API
#    or dashboard (Manage R2 API Tokens).
# 2. Access Key ID = the token's id.
# 3. Secret Access Key = SHA-256 hash of the token's value:
echo -n "<token-value>" | shasum -a 256
```

## Self-host (docker-compose)

Uncomment the `backup` service in `docker-compose.yml` and set the same
`AWS_*`/`S3_*` vars in `.env`. It's `profiles: ["backup"]`-gated so it doesn't
run unless you opt in:

```bash
docker compose --profile backup run --rm backup   # one-off test run
```

For a recurring schedule outside Railway, run it via host `cron` or any
scheduler that can `docker compose run backup`.

## Restore

**This is destructive — it replaces the target database's contents.** Restore
into a *new* database first and verify before pointing production at it.

```bash
# 1. Download the backup you want
aws s3 cp s3://<bucket>/postgres/<timestamp>.sql.gz . \
  --endpoint-url https://<account-id>.r2.cloudflarestorage.com
gunzip <timestamp>.sql.gz

# 2. Restore into a FRESH database (never restore over a live one blind)
createdb -h <host> -U <user> stash_restore_test
psql -h <host> -U <user> -d stash_restore_test -f <timestamp>.sql

# 3. Verify — row counts, spot-check recent memories
psql -h <host> -U <user> -d stash_restore_test -c \
  "SELECT count(*) FROM episodes; SELECT count(*) FROM facts;"

# 4. Only after verifying: point Stash's DATABASE_URL/STASH_POSTGRES_DSN at
#    the restored database, or rename it into place during a maintenance
#    window (rename the broken DB aside, rename stash_restore_test to take
#    its place, restart the stash service).
```

## What backup does NOT cover

- **Point-in-time recovery** — this is periodic full dumps (default daily),
  not continuous WAL archiving. Data written between backups is lost if the
  primary fails. If you need PITR, use your Postgres provider's native
  feature (Railway, RDS, etc. — check what your plan includes) in addition to
  this.
- **Secrets/config** — `STASH_TOKEN`, provider API keys, etc. live in your
  deploy platform's variable store, not in this backup. Keep those recorded
  somewhere durable separately (e.g. GCP Secret Manager, 1Password).
