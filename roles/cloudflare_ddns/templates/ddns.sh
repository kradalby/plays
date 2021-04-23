#!/usr/bin/env bash

source {{ prometheus_bash_client_path }}/prometheus.bash
io::prometheus::NewGauge name=cloudflare_ddns_start_time_seconds help='Start time of the process since unix epoch in seconds.'
cloudflare_ddns_start_time_seconds set $(date +%s)

{% if cloudflare_ipv4_dns_id | length %}
IPv4_CURRENT="$(dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com | sed 's/"//g')"
{% endif %}
{% if cloudflare_ipv6_dns_id | length %}
IPv6_CURRENT="$(dig -6 TXT +short o-o.myaddr.l.google.com @ns1.google.com | sed 's/"//g')"
{% endif %}

{% if cloudflare_ipv4_dns_id | length %}
IPv4_FILE="/tmp/last_ipv4.txt"
{% endif %}
{% if cloudflare_ipv6_dns_id | length %}
IPv6_FILE="/tmp/last_ipv6.txt"
{% endif %}

{ IPv4_STORED=$(<$IPv4_FILE); } 2>/dev/null
{% if cloudflare_ipv6_dns_id | length %}
{ IPv6_STORED=$(<$IPv6_FILE); } 2>/dev/null
{% endif %}

{% if cloudflare_ipv4_dns_id | length %}
if [ "$IPv4_CURRENT" != "$IPv4_STORED" ]; then
    echo $IPv4_CURRENT >$IPv4_FILE
    curl -X PUT "https://api.cloudflare.com/client/v4/zones/{{ cloudflare_zone_id }}/dns_records/{{ cloudflare_ipv4_dns_id }}" \
        -H "Authorization: Bearer {{ cloudflare_token }}" \
        -H "Content-Type: application/json" \
        --data '{"type":"A","name":"{{ cloudflare_dns_name }}","content":"'"$IPv4_CURRENT"'","proxied":false,"ttl":"120"}' |
        jq
fi
{% endif %}

{% if cloudflare_ipv6_dns_id | length %}
if [ "$IPv6_CURRENT" != "$IPv6_STORED" ]; then
    echo $IPv6_CURRENT >$IPv6_FILE
    curl -X PUT "https://api.cloudflare.com/client/v4/zones/{{ cloudflare_zone_id }}/dns_records/{{ cloudflare_ipv6_dns_id }}" \
        -H "Authorization: Bearer {{ cloudflare_token }}" \
        -H "Content-Type: application/json" \
        --data '{"type":"AAAA","name":"{{ cloudflare_dns_name }}","content":"'"$IPv6_CURRENT"'","proxied":false,"ttl":"120"}' |
        jq
fi
{% endif %}

io::prometheus::NewGauge name=cloudflare_ddns_end_time_seconds help='End time of the process since unix epoch in seconds.'
cloudflare_ddns_end_time_seconds set $(date +%s)

io::prometheus::PushAdd \
    job="ddns_update" \
    instance="{{ inventory_hostname }}" \
    gateway="{{ pushgateway }}"
