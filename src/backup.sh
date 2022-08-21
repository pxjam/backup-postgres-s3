#!/bin/bash

echo "CRON MAKES BACKUP OF $BAKPGS3_PROJECT_NAME AT $(date)"

rm -f /root/*.sql.gz

DUMP_FILENAME="/root/${BAKPGS3_PROJECT_NAME}.$(date '+%F').sql.gz"
export PGPASSWORD="$BAKPGS3_PASSWORD"

pg_dump --format=custom \
	-h "$BAKPGS3_HOST" \
	-p 5432 \
	-U "$BAKPGS3_USER" \
	-d "$BAKPGS3_DATABASE" |
	gzip >"$DUMP_FILENAME"

s3cmd put "$DUMP_FILENAME" "s3://$BAKPGS3_BUCKET"
