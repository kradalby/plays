#!/usr/bin/env bash

{% if cloudflare_ipv4_dns_id|length %}
IPv4_CURRENT="$(dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com | sed 's/"//g')"
{% endif %}
{% if cloudflare_ipv6_dns_id|length %}
IPv6_CURRENT="$(dig -6 TXT +short o-o.myaddr.l.google.com @ns1.google.com | sed 's/"//g')"
{% endif %}

{% if cloudflare_ipv4_dns_id|length %}
IPv4_FILE="/tmp/last_ipv4.txt"
{% endif %}
{% if cloudflare_ipv6_dns_id|length %}
IPv6_FILE="/tmp/last_ipv6.txt"
{% endif %}

IPv4_STORED="$(cat $IPv4_FILE)"
{% if cloudflare_ipv6_dns_id|length %}
IPv6_STORED="$(cat $IPv6_FILE)"
{% endif %}

{% if cloudflare_ipv4_dns_id|length %}
if [ "$IPv4_CURRENT" != "$IPv4_STORED" ]; then
    echo $IPv4_CURRENT >$IPv4_FILE
    curl -X PUT "https://api.cloudflare.com/client/v4/zones/{{ cloudflare_zone_id }}/dns_records/{{ cloudflare_ipv4_dns_id }}" \
        -H "Authorization: Bearer {{ cloudflare_token }}" \
        -H "Content-Type: application/json" \
        --data '{"type":"A","name":"{{ cloudflare_dns_name }}","content":"'"$IPv4_CURRENT"'","proxied":false,"ttl":"120"}' |
        jq
fi
{% endif %}

{% if cloudflare_ipv6_dns_id|length %}
if [ "$IPv6_CURRENT" != "$IPv6_STORED" ]; then
    echo $IPv6_CURRENT >$IPv6_FILE
    curl -X PUT "https://api.cloudflare.com/client/v4/zones/{{ cloudflare_zone_id }}/dns_records/{{ cloudflare_ipv6_dns_id }}" \
        -H "Authorization: Bearer {{ cloudflare_token }}" \
        -H "Content-Type: application/json" \
        --data '{"type":"AAAA","name":"{{ cloudflare_dns_name }}","content":"'"$IPv6_CURRENT"'","proxied":false,"ttl":"120"}' |
        jq
fi
{% endif %}
