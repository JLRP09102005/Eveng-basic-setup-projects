#!/bin/bash

BASE_DIR="$(cd "${BASH_SOURCE[0]}" && pwd)"

#Move the Cisco License Generator to the base directory
cp "${BASE_DIR}/python3/CiscoIOUKeygen3f.py" "/opt/unetlab/addons/iol/bin/"

#Create symbolic link
ln -sf "/opt/unetlab/addons/iol/bin/iourc" "/root/.iourc"
ln -sf "/opt/unetlab/addons/iol/bin/iourc" "/opt/unetlab/wrappers/iourc"

#Create netIO directory
mkdir -p /tmp/netio0
chmod 777 /tmp/netio0

#Download and install 32-bit libraries
echo 'd /tmp/netio0 0777 root root -' > /etc/tmpfiles.d/netio0.conf

#Binary permissions por IOL
