#!/usr/bin/env bash
set -euxo pipefail

socat -u UDP4-RECVFROM:5353,ip-add-membership=224.0.0.251:{{ ansible_default_ipv4.address|default(ansible_all_ipv4_addresses[0]) }},reuseaddr,fork - | tee \
    {% for host in groups['socat_mdns'] | difference(inventory_hostname) %}
    >(socat -u - UDP4-SENDTO:{{ host }}:55353) \
    {% endfor %}
    2>&1 >/dev/null
