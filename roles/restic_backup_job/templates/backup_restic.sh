#!/usr/bin/env bash

set -euo pipefail

RESTIC=/usr/local/bin/restic
export RESTIC_PASSWORD='{{ restic_backup_job_password }}'

export RESTIC_REPOSITORY='{{ item }}'

echo "Doing backup to $RESTIC_REPOSITORY"

$RESTIC snapshots > /dev/null || $RESTIC init

$RESTIC unlock

$RESTIC backup --verbose {{ restic_backup_job_directories | join(" ") }}

$RESTIC check
$RESTIC snapshots

$RESTIC forget \
    --keep-hourly 8 \
    --keep-daily 7 \
    --keep-weekly 4 \
    --keep-monthly 6 \
    --keep-yearly 10

$RESTIC prune

exit 0

