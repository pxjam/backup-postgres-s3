#!/bin/bash

log() {
	echo -e "$1"
	echo -e "$1" >>/app/logs/backup.log
}

if [ -n "$BAKPGS3_DB_PASSWORD" ]; then
	db_password="$BAKPGS3_DB_PASSWORD"
else
	db_password=$(cat /run/secrets/bakpgs3_db_password 2>/dev/null)
fi

echo "BACKUP STARTED FOR $BAKPGS3_PROJECT_NAME AT $(date)"

tmp_dir="/app/tmp"
mkdir -p "$tmp_dir"
rm -f "$tmp_dir"/*.sql.gz

datetime=$(date '+%F_%H-%M-%S')
dump_filename="$BAKPGS3_PROJECT_NAME.$datetime.sql.gz"
dump_filepath="$tmp_dir/$dump_filename"

export PGPASSWORD="$db_password"

echo "Creating database dump..."
pg_dump --encoding utf8 \
	-h "$BAKPGS3_DB_HOST" \
	-p 5432 \
	-U "$BAKPGS3_DB_USER" \
	-d "$BAKPGS3_DB_DATABASE" |
	gzip >"$dump_filepath"

if [ ${PIPESTATUS[0]} -ne 0 ]; then
	log "ERR:\t$datetime\tDatabase dump failed"
	rm -f "$dump_filepath"
	exit 1
fi

file_size=$(du -h "$dump_filepath" | cut -f1)
echo "DB dump created: $dump_filename ($file_size)"

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

echo "Uploading backup to: $BAKPGS3_S3_BUCKET/$storage_dir/"
rclone copy "$dump_filepath" "default:$BAKPGS3_S3_BUCKET/$storage_dir/"

if [ $? -eq 0 ]; then
	echo "Backup uploaded successfully"
	rm -f "$dump_filepath"
	log "OK:\t$datetime\t$storage_dir\t$dump_filename\t$file_size"
else
	log "ERR:\t$datetime\tUpload failed"
	exit 1
fi
