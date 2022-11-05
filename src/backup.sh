#!/bin/bash

echo "CRON MAKES BACKUP OF $BAKPGS3_PROJECT_NAME AT $(date)"

rm -f /root/*.sql.gz

DUMP_FILENAME="/root/${BAKPGS3_PROJECT_NAME}.$(date '+%F').sql.gz"

export PGPASSWORD="$BAKPGS3_DB_PASSWORD"

pg_dump --encoding utf8 \
	-h "$BAKPGS3_DB_HOST" \
	-p 5432 \
	-U "$BAKPGS3_DB_USER" \
	-d "$BAKPGS3_DB_DATABASE" |
	gzip >"$DUMP_FILENAME"

MONTH_DAY=$(date +%d)
WEEK_DAY=$(date +%u)

if [ "$MONTH_DAY" == "01" ]; then
	DIR="monthly"
elif [ "$WEEK_DAY" == "1" ]; then
	DIR="weekly"
else
	DIR="daily"
fi

s3cmd put "$DUMP_FILENAME" "s3://$BAKPGS3_S3_BUCKET/$DIR/"
