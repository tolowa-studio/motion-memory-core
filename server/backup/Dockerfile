# Motion Memory Core — scheduled Postgres backup.
# Runs `pg_dump` on a cron schedule, gzips, and uploads to any S3-compatible
# object store (Cloudflare R2 by default). Nothing here is memory-core-specific
# beyond the default bucket naming — it's a generic pg_dump-to-S3 job.
FROM alpine:3.20
RUN apk add --no-cache postgresql16-client aws-cli bash python3
COPY backup.sh /backup.sh
RUN chmod +x /backup.sh
ENTRYPOINT ["/backup.sh"]
