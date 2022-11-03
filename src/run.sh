#!/bin/bash

echo "Starting container $HOSTNAME"

[ -z "$BAKPGS3_PROJECT_NAME" ] && { echo "FAIL: please specify \$BAKPGS3_PROJECT_NAME env variable" && exit 1; }
[ -z "$BAKPGS3_CRON_TIME" ] && { echo "FAIL: please specify \$BAKPGS3_CRON_TIME env variable" && exit 1; }
[ -z "$BAKPGS3_S3_ACCESS_KEY" ] && { echo "FAIL: please specify \$BAKPGS3_S3_ACCESS_KEY env variable" && exit 1; }
[ -z "$BAKPGS3_S3_SECRET_KEY" ] && { echo "FAIL: please specify \$BAKPGS3_S3_SECRET_KEY env variable" && exit 1; }
[ -z "$BAKPGS3_DB_USER" ] && { echo "FAIL: please specify \$BAKPGS3_DB_USER env variable" && exit 1; }
[ -z "$BAKPGS3_S3_REGION" ] && { echo "FAIL: please specify \$BAKPGS3_S3_REGION env variable" && exit 1; }

echo "
[default]
access_key = $BAKPGS3_S3_ACCESS_KEY
secret_key = $BAKPGS3_S3_SECRET_KEY
bucket_location = $BAKPGS3_S3_REGION
host_base = $BAKPGS3_S3_ENDPOINT
host_bucket = $BAKPGS3_S3_ENDPOINT
use_https = True
" >~/.s3cfg

service cron start

env >>/etc/environment
echo "
${BAKPGS3_CRON_TIME} /root/backup.sh >> /root/log.txt 2>&1
" >/root/crontab.conf

crontab /root/crontab.conf

source /root/backup.sh

tail -f /dev/null
