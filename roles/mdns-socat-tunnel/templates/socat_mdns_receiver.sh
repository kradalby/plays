#!/usr/bin/env bash

# {{ ansible_managed }}

set -euxo pipefail

socat -u UDP4-RECVFROM:55353,fork UDP-DATAGRAM:224.0.0.251:5353,ip-multicast-loop=0
