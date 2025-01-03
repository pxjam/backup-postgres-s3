#!/bin/bash

BAKPGS3_DB_PASSWORD=$(cat /run/secrets/bakpgs3_db_password)

echo "CRON MAKES BACKUP OF $BAKPGS3_PROJECT_NAME AT $(date)"

rm -f /root/*.sql.gz

dump_filename="/root/${BAKPGS3_PROJECT_NAME}.$(date '+%F').sql.gz"

export PGPASSWORD="$BAKPGS3_DB_PASSWORD"

pg_dump --encoding utf8 \
	-h "$BAKPGS3_DB_HOST" \
	-p 5432 \
	-U "$BAKPGS3_DB_USER" \
	-d "$BAKPGS3_DB_DATABASE" |
	gzip > "$dump_filename"

storage_dir="daily"

if [ "$(date +%u)" -eq 7 ]; then
	storage_dir="weekly"
elif [ "$(date +%d)" -eq 1 ]; then
	if [ "$(date +%m)" -eq 1 ]; then
		storage_dir="yearly"
	else
		storage_dir="monthly"
	fi
fi

echo "Today is $(date +%d.%m.%Y), so the backup will be stored in $storage_dir"

echo "Rclone copy $dump_filename to default:$BAKPGS3_S3_BUCKET/$storage_dir/"
rclone copy "$dump_filename" "default:$BAKPGS3_S3_BUCKET/$storage_dir/"
