#!/bin/bash
DIR={{ postgres_backup_dir }}
DATE=$(date -I)
[ ! $DIR ] && mkdir -p $DIR || :
mkdir -p $DIR/$DATE
LIST=$(psql -l | awk '{ print $1}' | grep -vE '^-|^List|^Name|template[0|1]|\||\([0-9]')
for d in $LIST
do
  pg_dump $d | xz -c >  $DIR/$DATE/$d.out.xz
done
