#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="/var/backups/db"
TIMESTAMP=$(date +"%Y%m%d")
ARCHIVE_NAME="db_backup_${TIMESTAMP}.sql.gz"
CONTAINER_NAME="db_postgres"
DB_USER="appuser"
DB_NAME="appdb"

mkdir -p "$BACKUP_DIR"

# Stream dump directly through gzip compression
docker exec -i "$CONTAINER_NAME" pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "${BACKUP_DIR}/${ARCHIVE_NAME}"

chmod 600 "${BACKUP_DIR}/${ARCHIVE_NAME}"
echo "Backup successfully written to: ${BACKUP_DIR}/${ARCHIVE_NAME}"
