#!/usr/bin/python
import ipaddress
import itertools
from typing import Any
from typing import Mapping
from typing import Sequence


def site_code(ipv4):
    # Verify IP address
    _ = ipaddress.ip_address(ipv4)

    segments = ipv4.split(".")

    return int(segments[1])


# rest:https://restic.storage.tjoda.fap.no/rpi1.ldn.fap.no
# rclone:Jotta:storage.tjoda.fap.no
# /Volumes/storage/restic/kramacbook
def restic_repo_friendly_name(repo: str) -> str:
    if "https://" in repo:
        repo = repo.replace("https://", "")
        print(repo)
        type_, address, *_ = repo.split(":")
        (r, *_) = address.split("/")
        return "_".join([type_, r]).replace(".", "_")
    elif ":" not in repo:
        # Most likely a file path
        type_ = "disk"
        path = list(filter(None, repo.split("/")))
        if path[0] == "Volumes":
            return "_".join([type_, path[1]])

        return "_".join([type_, repo.replace("/", "_")])

    else:
        type_, *rest = repo.split(":")
        return "_".join([type_, rest[0]])


def path_to_systemd_mount(path: str) -> str:
    return path.replace("/", "-")[1:] + ".mount"


def filter_ethernets(interfaces: Sequence[Mapping]) -> Sequence[Mapping]:
    return [
        inf
        for inf in interfaces
        if "vlan" in inf and not inf["vlan"] and "bridge" in inf and not inf["bridge"]
    ]


def filter_bridges(interfaces: Sequence[Mapping]) -> Sequence[Mapping]:
    return [inf for inf in interfaces if "bridge" in inf and inf["bridge"]]


def filter_vlans(interfaces: Sequence[Mapping]) -> Sequence[Mapping]:
    return [inf for inf in interfaces if "vlan" in inf and inf["vlan"]]


def filter_dhcp(interfaces: Sequence[Mapping]) -> Sequence[Mapping]:
    return [inf for inf in interfaces if "dhcp_start" in inf and "dhcp_end" in inf]


def filter_wan(interfaces: Sequence[Mapping]) -> Mapping[Any, Any]:
    for inf in interfaces:
        if "wan" in inf and inf["wan"]:
            return inf
    return {}


def filter_lan(interfaces: Sequence[Mapping]) -> Sequence[Mapping]:
    return [inf for inf in interfaces if "lan" in inf and inf["lan"]]


def filter_restricted(interfaces: Sequence[Mapping]) -> Sequence[Mapping]:
    return [
        inf
        for inf in filter_lan(interfaces)
        if "restricted" in inf and inf["restricted"]
    ]


def filter_nonrestricted(interfaces: Sequence[Mapping]) -> Sequence[Mapping]:
    return [
        inf
        for inf in filter_lan(interfaces)
        if "restricted" not in inf or not inf["restricted"]
    ]


def interfaces_names(interfaces: Sequence[Mapping]) -> Sequence[str]:
    return [inf["name"] for inf in interfaces]


def interfaces_addresses(interfaces: Sequence[Mapping]) -> Sequence[str]:
    return list(
        itertools.chain.from_iterable(
            [inf["netplan"]["addresses"] for inf in interfaces],
        ),
    )


def router_id(interfaces: Sequence[Mapping]) -> Sequence[str]:
    main = [inf for inf in filter_lan(interfaces) if inf["name"] == "br0"][0]
    return main["netplan"]["addresses"][0].split("/")[0]


class FilterModule:
    def filters(self):
        return {
            "site_code": site_code,
            "restic_repo_friendly_name": restic_repo_friendly_name,
            "path_to_systemd_mount": path_to_systemd_mount,
            "filter_ethernets": filter_ethernets,
            "filter_bridges": filter_bridges,
            "filter_vlans": filter_vlans,
            "filter_dhcp": filter_dhcp,
            "filter_wan": filter_wan,
            "filter_lan": filter_lan,
            "filter_restricted": filter_restricted,
            "filter_nonrestricted": filter_nonrestricted,
            "filter_inf_names": interfaces_names,
            "filter_inf_addresses": interfaces_addresses,
            "filter_router_id": router_id,
        }
