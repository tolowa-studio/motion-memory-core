#!/usr/bin/env bash
# Motion Memory Core — backup.sh
#
# One-shot: pg_dump -> gzip -> upload to S3-compatible storage -> prune old
# backups past RETENTION_DAYS. Designed to run as a scheduled job (Railway
# cronSchedule, a k8s CronJob, cron(1) — anything that runs a container on a
# schedule and exits). Every failure is loud (set -euo pipefail, no swallowed
# errors) so a broken backup fails the job instead of silently no-op'ing.
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL is required}"
: "${S3_BUCKET:?S3_BUCKET is required}"
: "${S3_ENDPOINT_URL:?S3_ENDPOINT_URL is required (e.g. https://<account>.r2.cloudflarestorage.com)}"
: "${AWS_ACCESS_KEY_ID:?AWS_ACCESS_KEY_ID is required}"
: "${AWS_SECRET_ACCESS_KEY:?AWS_SECRET_ACCESS_KEY is required}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
PREFIX="${S3_PREFIX:-postgres}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-auto}"

TS="$(date -u +%Y-%m-%dT%H-%M-%SZ)"
FILE="/tmp/backup-${TS}.sql.gz"

echo "[backup] dumping database..."
pg_dump --no-owner --no-privileges "${DATABASE_URL}" | gzip -9 > "${FILE}"

SIZE=$(stat -c%s "${FILE}" 2>/dev/null || stat -f%z "${FILE}")
if [ "${SIZE}" -lt 1024 ]; then
  echo "[backup] FATAL: dump is suspiciously small (${SIZE} bytes) — refusing to upload a likely-broken backup" >&2
  exit 1
fi
echo "[backup] dump ok: ${SIZE} bytes"

DEST="s3://${S3_BUCKET}/${PREFIX}/${TS}.sql.gz"
echo "[backup] uploading to ${DEST}..."
aws s3 cp "${FILE}" "${DEST}" --endpoint-url "${S3_ENDPOINT_URL}"
rm -f "${FILE}"

echo "[backup] verifying upload..."
aws s3api head-object --bucket "${S3_BUCKET}" --key "${PREFIX}/${TS}.sql.gz" --endpoint-url "${S3_ENDPOINT_URL}" >/dev/null
echo "[backup] verified: ${DEST} (${SIZE} bytes)"

echo "[backup] pruning backups older than ${RETENTION_DAYS} days..."
# Computed in Python, not shell `date`, since GNU/BSD/BusyBox date all parse
# relative offsets ("-30 days") differently and this must work identically in
# the Alpine/BusyBox container and on a developer's Mac.
CUTOFF=$(python3 -c "import datetime; print(int((datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(days=${RETENTION_DAYS})).timestamp()))")
aws s3api list-objects-v2 --bucket "${S3_BUCKET}" --prefix "${PREFIX}/" --endpoint-url "${S3_ENDPOINT_URL}" \
  --query "Contents[].{Key:Key,LastModified:LastModified}" --output json 2>/dev/null | \
python3 -c "
import json, sys, datetime
cutoff = ${CUTOFF}
try:
    items = json.load(sys.stdin) or []
except Exception:
    items = []
for it in items:
    lm = datetime.datetime.strptime(it['LastModified'][:19], '%Y-%m-%dT%H:%M:%S')
    if lm.replace(tzinfo=datetime.timezone.utc).timestamp() < cutoff:
        print(it['Key'])
" | while read -r KEY; do
  [ -n "${KEY}" ] || continue
  echo "[backup] pruning ${KEY}"
  aws s3 rm "s3://${S3_BUCKET}/${KEY}" --endpoint-url "${S3_ENDPOINT_URL}"
done

echo "[backup] done."
