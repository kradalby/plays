#!/usr/bin/env bash

BACKUP_COUNT_UNIQUE=`fdfind out.xz {{ postgres_backup_dir }} -x basename | uniq | wc -l`
BACKUP_COUNT=`fdfind out.xz {{ postgres_backup_dir }} -x basename | wc -l`

if [ "$BACKUP_COUNT" -lt "{{ postgres_minimum_total_backups }}" ] || [ "$BACKUP_COUNT_UNIQUE" -lt "{{ postgres_minimum_unique_backups }}" ]; then
    echo "Postgres is not taking creating new backups, unique backups: $BACKUP_COUNT_UNIQUE, total: $BACKUP_COUNT"
    exit 1
fi

exit 0

