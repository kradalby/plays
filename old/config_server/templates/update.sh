#!/usr/bin/env bash

hostname=$(hostname)
domain=$(hostname -d)
ip=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
os=$(lsb_release -d -s)
uptime=$(uptime -p)
load=$(cat /proc/loadavg)

curl -i --silent \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
-X POST --data '{"internal":"'"$ip"'","hostname":"'"$hostname"'","domain":"'"$domain"'","os":"'"$os"'","uptime":"'"$uptime"'","load":"'"$load"'"}' \
"https://fap.no/api/v1/server/update"
