#!/usr/bin/env bash

source {{ prometheus_bash_client_path }}/prometheus.bash
io::prometheus::NewGauge name=postgres_backup_start_time_seconds help='Start time of the process since unix epoch in seconds.'
postgres_backup_start_time_seconds set "$(date +%s)"

BACKUP_COUNT_UNIQUE=$(fdfind out.xz {{ postgres_backup_dir }} -x basename | sort -u | wc -l)
BACKUP_COUNT=$(fdfind out.xz {{ postgres_backup_dir }} -x basename | wc -l)

io::prometheus::NewGauge name=postgres_backup_count help='Total number of postgres backups (Day * Databases)'
postgres_backup_count set "$BACKUP_COUNT"
io::prometheus::NewGauge name=postgres_backup_count_unique help='Number of unique postgres backups'
postgres_backup_count_unique set "$BACKUP_COUNT_UNIQUE"

if [ "$BACKUP_COUNT" -lt "{{ postgres_minimum_total_backups }}" ] || [ "$BACKUP_COUNT_UNIQUE" -lt "{{ postgres_minimum_unique_backups }}" ]; then
    echo "Postgres is not taking creating new backups, unique backups: $BACKUP_COUNT_UNIQUE, total: $BACKUP_COUNT"
    exit 1
fi

io::prometheus::NewGauge name=postgres_backup_end_time_seconds help='End time of the process since unix epoch in seconds.'
postgres_backup_end_time_seconds set "$(date +%s)"

io::prometheus::PushAdd \
    job="count_backups" \
    instance="{{ inventory_hostname }}" \
    gateway="{{ pushgateway }}"

exit 0
