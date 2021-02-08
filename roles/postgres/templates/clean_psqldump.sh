#!/bin/bash


# https://superuser.com/questions/268344/how-do-i-delete-all-but-10-newest-files-in-linux/268414
# %T is timestamp
# %p is path with parent
find {{ postgres_backup_dir }} -maxdepth 1 -type d -printf '%Ts\t%p\n' | sort -n | head -n -11 | cut -f 2- | xargs rm -r
