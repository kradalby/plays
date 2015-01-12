#!/bin/bash
ssh-keygen -G "${HOME}/moduli" -b 4096
ssh-keygen -T /etc/ssh/moduli -f "${HOME}/moduli"
rm "${HOME}/moduli"
