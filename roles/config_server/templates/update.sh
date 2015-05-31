#!/bin/bash

hostname=$(hostname)
ip=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
os=$(lsb_release -d -s)
uptime=$(uptime)

curl -i --silent \
-H "Accept: application/json" \
-H "Content-Type:application/json" \
-X POST --data '{"internal":"'"$ip"'","hostname":"'"$hostname"'","os":"'"$os"'","uptime":"'"$uptime"'"}' \
"https://fap.no/api/v1/server/update"
