#!/usr/bin/python

import ipaddress


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


class FilterModule(object):
    def filters(self):
        return {
            "site_code": site_code,
            "restic_repo_friendly_name": restic_repo_friendly_name,
        }
