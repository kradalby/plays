#!/usr/bin/env python3

import subprocess
import re

#    physicaldrive 1I:1:5 (port 1I:box 1:bay 5, 256 GB): OK
#    physicaldrive 1I:1:6 (port 1I:box 1:bay 6, 256 GB): OK
#    physicaldrive 1I:1:7 (port 1I:box 1:bay 7, 4 TB): OK
#    physicaldrive 2I:1:1 (port 2I:box 1:bay 1, 300 GB): OK
#    physicaldrive 2I:1:2 (port 2I:box 1:bay 2, 300 GB): OK
#    physicaldrive 2I:1:3 (port 2I:box 1:bay 3, 300 GB): OK
#    physicaldrive 2I:1:4 (port 2I:box 1:bay 4, 300 GB): OK

command = ["/usr/sbin/ssacli", "ctrl", "slot=0", "pd", "all", "show", "status"]

result = [
    disk.strip()
    for disk in subprocess.run(command, capture_output=True, text=True).stdout.split(
        "\n"
    )
    if disk
]

disks = []

for disk in result:
    matches = re.search(
        r"^([a-z]+?) ([A-Z0-9:]{6}) \(port ([0-9][A-Z]):box ([0-9]):bay ([0-9]), ([0-9]+) ([A-Z]{2})\): ([A-Za-z]+)",
        disk,
    )
    disks.append(
        {
            "type": matches.group(1),
            "address": matches.group(2),
            "port": matches.group(3),
            "box": matches.group(4),
            "bay": matches.group(5),
            "capacity": matches.group(6),
            "unit": matches.group(7),
            "status": matches.group(8),
        }
    )

metrics = [
    """\
# HELP hp_smart_array_disk_status Disk status of a given disk in HP array, 1 = OK, 0 != OK
# TYPE hp_smart_array_disk_status gauge"""
]
for disk in disks:
    status = 1 if disk["status"] == "OK" else 0
    metric = f"""\
hp_smart_array_disk_status{{type="{disk['type']}", capacity="{disk['capacity']}{disk['unit']}", bay="{disk['bay']}"}} {status}"""
    metrics.append(metric)

with open("/var/lib/prometheus/node-exporter/ssacli.prom", "w") as f:
    f.write("\n".join(metrics) + "\n")
