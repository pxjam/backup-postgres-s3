#!/bin/bash

echo "Starting backup container $HOSTNAME"

[ -z "$BAKPGS3_PROJECT_NAME" ] && { echo "FAIL: please specify \$BAKPGS3_PROJECT_NAME env variable" && exit 1; }
[ -z "$BAKPGS3_DB_USER" ] && { echo "FAIL: please specify \$BAKPGS3_DB_USER env variable" && exit 1; }
[ -z "$BAKPGS3_S3_REGION" ] && { echo "FAIL: please specify \$BAKPGS3_S3_REGION env variable" && exit 1; }

if [ -n "$BAKPGS3_S3_ACCESS_KEY" ]; then
  s3_access_key="$BAKPGS3_S3_ACCESS_KEY"
else
  s3_access_key=$(cat /run/secrets/bakpgs3_s3_access_key 2>/dev/null)
fi

if [ -n "$BAKPGS3_S3_SECRET_KEY" ]; then
  s3_secret_key="$BAKPGS3_S3_SECRET_KEY"
else
  s3_secret_key=$(cat /run/secrets/bakpgs3_s3_secret_key 2>/dev/null)
fi

mkdir -p ~/.config/rclone/

echo "Creating rclone configuration..."
echo "
[default]
type = s3
provider = Other
env_auth = false
access_key_id = $s3_access_key
secret_access_key = $s3_secret_key
region = $BAKPGS3_S3_REGION
endpoint = $BAKPGS3_S3_ENDPOINT
no_check_bucket = true
bucket = $BAKPGS3_S3_BUCKET
" > ~/.config/rclone/rclone.conf

echo "Running backup..."
/app/backup.sh
