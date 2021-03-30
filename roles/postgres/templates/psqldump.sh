#!/bin/bash

source "{{ prometheus_bash_client_path }}/prometheus.bash"
io::prometheus::NewGauge name=postgres_backup_start_time_seconds help='Start time of the process since unix epoch in seconds.'
postgres_backup_start_time_seconds set "$(date +%s)"

DIR={{ postgres_backup_dir }}
DATE="$(date -I)"
[ ! "$DIR" ] && mkdir -p "$DIR" || :
mkdir -p "$DIR/$DATE"
LIST=$(psql -l | awk '{ print $1}' | grep -vE '^-|^List|^Name|template[0|1]|\||\([0-9]')
for database in $LIST; do
  pg_dump "$database" | xz -c >"$DIR/$DATE/$database.out.xz"
done

io::prometheus::NewGauge name=postgres_backup_database_count help='Total number of databases in Postgres and backup'
postgres_backup_database_count set "$(echo "$LIST" | wc -l)"

io::prometheus::NewGauge name=postgres_backup_database_size_bytes help='Size of the new backup just created'
postgres_backup_database_size_bytes set "$(du --bytes --summarize "$DIR/$DATE" | awk '{print $1}')"

io::prometheus::NewGauge name=postgres_backup_database_total_size_bytes help='Total size of all backed up databases'
postgres_backup_database_total_size_bytes set "$(du --bytes --summarize "$DIR" | awk '{print $1}')"

io::prometheus::NewGauge name=postgres_backup_end_time_seconds help='End time of the process since unix epoch in seconds.'
postgres_backup_end_time_seconds set "$(date +%s)"

io::prometheus::PushAdd \
  job="backup" \
  instance="{{ inventory_hostname }}" \
  gateway="{{ pushgateway }}"
