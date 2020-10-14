#!/usr/bin/python

import ipaddress


def site_code(ipv4):
    # Verify IP address
    _ = ipaddress.ip_address(ipv4)

    segments = ipv4.split(".")

    return int(segments[1])


class FilterModule(object):
    def filters(self):
        return {"site_code": site_code}
