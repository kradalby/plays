#!/bin/bash
# Author:
# https://github.com/ltpitt
#
# Please check README.md for install / usage instructions

###
# Configuration variables, customize if needed
###

# Usage:
# network-repair.sh <reboot_server: bool> <nic: string> <gateway_ips: [string]>

# Set gateway_ips to one or more ips that you want to check to declare network working or not.
# If any of the ips responds, the network is considered functional.
# A minimum of one ip is required, in the example below it shows how to check two different
# gateways using a space character as delimiter.
gateway_ips=("${@:3}")
# Set nic to your Network card name, as seen in ip output.
# If you have multiple interfaces and are currently online, you can find which is in use with:
# ip route get 1.1.1.1 | head -n1 | cut -d' ' -f5
nic="$2"
# Set network_check_threshold to the maximum number of failed checks that must fail
# before declaring the network as non functional.
network_check_threshold=5
# Set reboot_server to true if you want to reboot the system as a last
# option to fix wifi in case the normal restore procedure fails.
reboot_server=$1
# Set reboot_server to the desired amount of minutes, it is used to
# prevent reboot loops in case network is down for long time and reboot_server
# is enabled.
reboot_cycle=60
# Last boot file file location, also used to prevent reboot loop.
last_bootfile=/tmp/.last_net_autoboot

###
# Script logic
###

# Initializing the network check counter to zero.
network_check_tries=0

# This function is a simple logger, just adding datetime to messages.
function date_log {
    echo "$(date +'%Y-%m-%d %T') $1"
}

# This function checks connectivity to gateway_ips
function check_gateways {
    for ip in $gateway_ips; do
        ping -c 1 $ip > /dev/null 2>&1
        # The $? variable always contains the return code of the previous command.
        # In BASH return code 0 usually means that everything executed successfully.
        # In the next if we are checking if the ping command execution was successful.
        if [[ $? == 0 ]]; then
            return 0
        fi
    done
    return 1
}

function restart_wireguard {
    date_log "WireGuard was not working for the previous $network_check_tries checks."
    date_log "Restarting WireGuard"
    systemctl restart "wg-quick@$nic.service"
}


function reboot_machine {
    # If the gateway checks are NOT successful.
    if ! check_gateways; then
        if [ "$reboot_server" = true ]; then
            # If there's no last boot file or it's older than reboot_cycle.
            if [[ ! -f $last_bootfile || $(find $last_bootfile -mmin +$reboot_cycle -print) ]]; then
                touch $last_bootfile
                date_log "Network is still not working, rebooting"
                /sbin/reboot
            else
                date_log "Last auto reboot was less than $reboot_cycle minutes old"
            fi
        fi
    fi
}


function restart_nic {
    date_log "Network was not working for the previous $network_check_tries checks."
    date_log "Re-applying netplan configuration"
    /usr/sbin/netplan apply

    if ! check_gateways; then
        date_log "Network was not working for the previous $network_check_tries checks."
        date_log "Restarting $nic"
        # Trying wlan restart using ip command.
        /sbin/ip link set "$nic" down
        sleep 5
        /sbin/ip link set "$nic" up
        sleep 60
    fi

    if ! check_gateways; then
        reboot_machine
    fi
}

# date_log "Checking $nic by pinging ${gateway_ips[*]}, reboot is $reboot_server"

# This loop will run for network_check_tries times, in case there are
# network_check_threshold failures the network will be declared as
# not functional and the restart_wlan function will be triggered.
while [ $network_check_tries -lt $network_check_threshold ]; do
    # Increasing network_check_tries by 1
    network_check_tries=$((network_check_tries+1))

    # If the gateway checks are successful.
    if check_gateways; then
        # Network is up.
        # date_log "Network is working correctly" && 
        exit 0
    else
        # Network is down.
        date_log "Network is down, failed check number $network_check_tries of $network_check_threshold"
    fi

    # Once the network_check_threshold is reached call restart_wlan.
    if [ $network_check_tries -ge $network_check_threshold ]; then
        if [[ "$nic" == "wg*" ]]; then
            restart_wireguard
        else
            restart_nic
        fi  
    fi
    sleep 5
done
