#!/bin/bash

## DIRECTORIES
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEVICES_DIR="${BASE_DIR}/devices"
LOG_DIR="${BASE_DIR/logs}"
mkdir -p "$LOG_DIR"

## FILES DIR
LOG_FILE="${LOG_DIR}/$(date "+%Y%m%d_%H%M%S").log"

## URL
GITHUB_DEVICES_URL="https://github.com/JLRP09102005/Eveng-basic-setup-projects/releases/tag/Resources"

## GLOBAL VARIABLES
root_privileges="0"

#====== MAIN SCRIPT ======

#Check user privileges
if [ "$EUID" -eq 0 ] 2>/dev/null || [ "$(id -u 2>/dev/null)" -eq 0 ]; then root_privileges=1; fi
[ "$root_privileges" -ne 0 ] && { echo "ERROR: This script needs root privileges"; exit 1; }

#Check software
git --version &>/dev/null

#Git clone or pull of the devices release
git clone "$GITHUB_DEVICES_URL" "$DEVICES_DIR" 2>>"$LOG_FILE" || git -C "$DEVICES_DIR" pull 2>>"$LOG_FILE"

#Move the Cisco License Generator to the base directory
cp "${BASE_DIR}/python3/CiscoIOUKeygen3f.py" "/opt/unetlab/addons/iol/bin/"

#Create symbolic link
ln -sf "/opt/unetlab/addons/iol/bin/iourc" "/root/.iourc" 2>>"$LOG_FILE"
ln -sf "/opt/unetlab/addons/iol/bin/iourc" "/opt/unetlab/wrappers/iourc" 2>>"$LOG_FILE"

#Create netIO directory
mkdir -p /tmp/netio0
chmod 777 /tmp/netio0

#Download and install 32-bit libraries
echo 'd /tmp/netio0 0777 root root -' > /etc/tmpfiles.d/netio0.conf

#Binary permissions por IOL
dpkg --add-architecture i386
apt-get update
apt-get install -y libc6:i386 libgcc-s1:i386