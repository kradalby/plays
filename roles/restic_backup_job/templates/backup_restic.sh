#!/usr/bin/env bash

source {{ prometheus_bash_client_path }}/prometheus.bash
io::prometheus::NewGauge name=restic_backup_start_time_seconds help='Start time of the process since unix epoch in seconds.'
restic_backup_start_time_seconds set `date +%s`


ACTION=${2:-backup}

source "{{ restic_backup_job_configuration_path }}/$1"

SECONDS=0

set -euo pipefail

RESTIC_BACKUP_JSON=""
RESTIC_PRUNE_JSON=""

echo "Doing backup to $RESTIC_REPOSITORY"

if [ "$ACTION" = "backup" ] || [ "$ACTION" = "full" ]; then
    $RESTIC snapshots > /dev/null || $RESTIC init

    $RESTIC unlock

    RESTIC_BACKUP_JSON=`$RESTIC backup --json --verbose $RESTIC_EXCLUDES $RESTIC_DIRECTORIES | jq -r 'select(.message_type=="summary")'`

    if [ "$ACTION" = "full" ]; then
        $RESTIC check
        $RESTIC snapshots

        $RESTIC forget $RESTIC_RETENTION


        RESTIC_PRUNE_JSON=`$RESTIC prune --json`

        $RESTIC cache --cleanup --max-age $RESTIC_CACHE_MAX_AGE
    fi
fi

DURATION=$SECONDS
END_TIME=`date +%s`


files=$(echo $RESTIC_BACKUP_JSON | jq -r '.total_files_processed')
bytes=$(echo $RESTIC_BACKUP_JSON | jq -r '.total_bytes_processed')
files_new=$(echo $RESTIC_BACKUP_JSON | jq -r '.files_new')
files_changed=$(echo $RESTIC_BACKUP_JSON | jq -r '.files_changed')
files_unchanged=$(echo $RESTIC_BACKUP_JSON | jq -r '.files_unmodified')
dirs_new=$(echo $RESTIC_BACKUP_JSON | jq -r '.dirs_new')
dirs_changed=$(echo $RESTIC_BACKUP_JSON | jq -r '.dirs_changed')
dirs_unchanged=$(echo $RESTIC_BACKUP_JSON | jq -r '.dirs_unmodified')

io::prometheus::NewGauge name=restic_backup_time_seconds help='How long the backup took'
restic_backup_time_seconds set "$DURATION"

io::prometheus::NewGauge name=restic_backup_end_time_seconds help='End time of the process since unix epoch in seconds.'
restic_backup_end_time_seconds set "$END_TIME"

io::prometheus::NewGauge name=restic_backup_processed_files help='How many files where processed'
restic_backup_processed_files set "$files"

io::prometheus::NewGauge name=restic_backup_processed_bytes help='How many bytes where processed'
restic_backup_processed_bytes set "$bytes"

io::prometheus::NewGauge name=restic_backup_files_new help='How many new files were backed-up'
restic_backup_files_new set "$files_new"

io::prometheus::NewGauge name=restic_backup_files_changed help='How many files were changed'
restic_backup_files_changed set "$files_changed"

io::prometheus::NewGauge name=restic_backup_files_unchanged help='How many files did not change'
restic_backup_files_unchanged set "$files_unchanged"

io::prometheus::NewGauge name=restic_backup_dirs_new help='How many new dirs were backed-up'
restic_backup_dirs_new set "$dirs_new"

io::prometheus::NewGauge name=restic_backup_dirs_changed help='How many dirs were changed'
restic_backup_dirs_changed set "$dirs_changed"

io::prometheus::NewGauge name=restic_backup_dirs_unchanged help='How many dirs did not change'
restic_backup_dirs_unchanged set "$dirs_unchanged"

io::prometheus::PushAdd \
    job="restic_backup" \
    instance="{{ inventory_hostname }}" \
    gateway="{{ pushgateway }}" \
    path="target/$RESTIC_REPOSITORY_FRIENDLY_NAME"

echo "Total time spend is pasted below:"
echo "$(($DURATION / 60)) minutes and $(($DURATION % 60)) seconds elapsed."

exit 0
