#!/bin/bash

echo "Starting container $HOSTNAME"

[ -z "$BAKPGS3_PROJECT_NAME" ] && { echo "FAIL: please specify \$BAKPGS3_PROJECT_NAME env variable" && exit 1; }
[ -z "$BAKPGS3_CRON_TIME" ] && { echo "FAIL: please specify \$BAKPGS3_CRON_TIME env variable" && exit 1; }
[ -z "$BAKPGS3_DB_USER" ] && { echo "FAIL: please specify \$BAKPGS3_DB_USER env variable" && exit 1; }
[ -z "$BAKPGS3_S3_REGION" ] && { echo "FAIL: please specify \$BAKPGS3_S3_REGION env variable" && exit 1; }

BAKPGS3_S3_ACCESS_KEY=$(cat /run/secrets/bakpgs3_s3_access_key)
BAKPGS3_S3_SECRET_KEY=$(cat /run/secrets/bakpgs3_s3_secret_key)

mkdir -p ~/.config/rclone/

echo "
[default]
type = s3
provider = Other
env_auth = false
access_key_id = $BAKPGS3_S3_ACCESS_KEY
secret_access_key = $BAKPGS3_S3_SECRET_KEY
region = $BAKPGS3_S3_REGION
endpoint = $BAKPGS3_S3_ENDPOINT
no_check_bucket = true
bucket = $BAKPGS3_S3_BUCKET
" > ~/.config/rclone/rclone.conf

service cron start

env >> /etc/environment
echo "
${BAKPGS3_CRON_TIME} /root/backup.sh >> /root/log.txt 2>&1
" > /root/crontab.conf

crontab /root/crontab.conf

source /root/backup.sh

tail -f /dev/null
