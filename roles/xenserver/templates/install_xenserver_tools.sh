#!/bin/bash
cd /root
wget https://kradalby.no/pub/xen_tools.tar.gz
tar xvfz xen_tools.tar.gz
/root/Linux/install.sh -n
rm -rf Linux/
rm xen_tools.tar.gz
