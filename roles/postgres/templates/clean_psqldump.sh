#!/bin/bash

source {{ prometheus_bash_client_path }}/prometheus.bash
io::prometheus::NewGauge name=postgres_backup_start_time_seconds help='Start time of the process since unix epoch in seconds.'
postgres_backup_start_time_seconds set "$(date +%s)"

# https://superuser.com/questions/268344/how-do-i-delete-all-but-10-newest-files-in-linux/268414
# %T is timestamp
# %p is path with parent
find {{ postgres_backup_dir }} -maxdepth 1 -type d -printf '%Ts\t%p\n' | sort -n | head -n -11 | cut -f 2- | xargs rm -r

io::prometheus::NewGauge name=postgres_backup_end_time_seconds help='End time of the process since unix epoch in seconds.'
postgres_backup_end_time_seconds set "$(date +%s)"

io::prometheus::PushAdd \
    job="clean_old_backups" \
    instance="{{ inventory_hostname }}" \
    gateway="{{ pushgateway }}"
