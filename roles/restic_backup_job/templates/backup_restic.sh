#!/usr/bin/env bash

{% set excludes = restic_backup_job_excludes | map('regex_replace', '^', '--exclude=') | list | join(" ") -%}

ACTION=${1:-backup}

SECONDS=0

set -euo pipefail

RESTIC=/usr/local/bin/restic
export RESTIC_PASSWORD='{{ restic_backup_job_password }}'

export RESTIC_REPOSITORY='{{ item }}'

echo "Doing backup to $RESTIC_REPOSITORY"

if [ "$ACTION" = "backup" ] || [ "$ACTION" = "full" ]; then
    $RESTIC snapshots > /dev/null || $RESTIC init

    $RESTIC unlock

    $RESTIC backup --verbose {{ excludes }} {{ restic_backup_job_directories | join(" ") }}

    if [ "$ACTION" = "full" ]; then
        $RESTIC check
        $RESTIC snapshots

        $RESTIC forget \
            --keep-hourly 8 \
            --keep-daily 7 \
            --keep-weekly 4 \
            --keep-monthly 6 \
            --keep-yearly 10

        $RESTIC prune
    fi
fi

DURATION=$SECONDS

echo "Total time spend is pasted below:"
echo "$(($DURATION / 60)) minutes and $(($DURATION % 60)) seconds elapsed."

exit 0