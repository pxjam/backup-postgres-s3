#!/bin/bash

# Log function to write to both stdout and log file
log() {
    echo "$1" | tee -a /logs/backup.log
}

# Get DB password from env var or secret
if [ -n "$BAKPGS3_DB_PASSWORD" ]; then
  db_password="$BAKPGS3_DB_PASSWORD"
else
  db_password=$(cat /run/secrets/bakpgs3_db_password 2>/dev/null)
fi

log "BACKUP STARTED FOR $BAKPGS3_PROJECT_NAME AT $(date)"

# Clean up any existing dump files in container
rm -f /tmp/*.sql.gz

dump_filename="/tmp/${BAKPGS3_PROJECT_NAME}.$(date '+%F_%H-%M-%S').sql.gz"

export PGPASSWORD="$db_password"

log "Creating database dump..."
pg_dump --encoding utf8 \
	-h "$BAKPGS3_DB_HOST" \
	-p 5432 \
	-U "$BAKPGS3_DB_USER" \
	-d "$BAKPGS3_DB_DATABASE" |
	gzip > "$dump_filename"

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    log "ERROR: Database dump failed"
    rm -f "$dump_filename"
    exit 1
fi

log "Database dump created: $dump_filename ($(du -h "$dump_filename" | cut -f1))"

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

log "Today is $(date +%d.%m.%Y), so the backup will be stored in $storage_dir"

log "Uploading backup to S3: $BAKPGS3_S3_BUCKET/$storage_dir/"
rclone copy "$dump_filename" "default:$BAKPGS3_S3_BUCKET/$storage_dir/"

if [ $? -eq 0 ]; then
    log "Backup uploaded successfully"
    # Clean up the temporary dump file
    rm -f "$dump_filename"
    log "Temporary dump file cleaned up"
else
    log "ERROR: Backup upload failed"
    exit 1
fi

log "BACKUP COMPLETED FOR $BAKPGS3_PROJECT_NAME AT $(date)"
