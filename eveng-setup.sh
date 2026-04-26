#!/bin/bash

## DIRECTORIES
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
QEMU_DIR="/opt/unetlab/addons/qemu"
BIN_DIR="/opt/unetlab/addons/iol/bin"

LOG_DIR="${BASE_DIR}/logs"
mkdir -p "$LOG_DIR"

DEVICES_DIR="${BASE_DIR}/devices"
mkdir -p "$DEVICES_DIR"

## FILES DIR
LOG_FILE="${LOG_DIR}/$(date "+%Y%m%d_%H%M%S").log"

## URL
ASAV9181_LINK="https://github.com/JLRP09102005/Eveng-basic-setup-projects/releases/download/Resources/asav9181.qcow2"
ASAV983_LINK="https://github.com/JLRP09102005/Eveng-basic-setup-projects/releases/download/Resources/asav983.qcow2"
CSR1000_LINK="https://github.com/JLRP09102005/Eveng-basic-setup-projects/releases/download/Resources/csr1000.qcow2"
SWITCHL2_LINK="https://github.com/JLRP09102005/Eveng-basic-setup-projects/releases/download/Resources/i86bi-linux-l2-adventerprisek9-15.1a.bin"
SWITCHL3_LINK="https://github.com/JLRP09102005/Eveng-basic-setup-projects/releases/download/Resources/i86bi-linux-l3-jk9s-15.0.1.bin"

## GLOBAL VARIABLES
root_privileges="0"

#====== MAIN SCRIPT ======
clear

#Check user privileges
if [ "$EUID" -eq 0 ] 2>/dev/null || [ "$(id -u 2>/dev/null)" -eq 0 ] 2>/dev/null; then root_privileges=1; fi
[ "$root_privileges" -ne 1 ] && { echo "ERROR: This script needs root privileges"; exit 1; }

#Check software
git --version &>/dev/null || sudo apt install git
python3 --version &>/dev/null || sudo apt install python3

#Git clone or pull of the devices release
git clone "$GITHUB_DEVICES_URL" "$DEVICES_DIR" 2>>"$LOG_FILE" || git -C "$DEVICES_DIR" pull 2>>"$LOG_FILE"

#Move the Cisco License Generator to the base directory
cp "${BASE_DIR}/python3/CiscoIOUKeygen3f.py" "/opt/unetlab/addons/iol/bin/"

#Execute Cisco License python script to generate iourc file
python3 /opt/unetlab/addons/iol/bin/CiscoIOUKeygen3f.py
chmod 644 /opt/unetlab/addons/iol/bin/iourc

#Create symbolic link
ln -sf "/opt/unetlab/addons/iol/bin/iourc" "/root/.iourc" 2>>"$LOG_FILE"
ln -sf "/opt/unetlab/addons/iol/bin/iourc" "/opt/unetlab/wrappers/iourc" 2>>"$LOG_FILE"

#Create netIO directory
mkdir -p /tmp/netio0
chmod 777 /tmp/netio0

#Download and install 32-bit libraries
echo 'd /tmp/netio0 0777 root root -' > /etc/tmpfiles.d/netio0.conf

#Binary permissions por IOL
if ! dpkg --print-foreign-architectures | grep "i386"; then
    dpkg --add-architecture i386
    apt-get update
    apt-get install -y libc6:i386 libgcc-s1:i386
else
    echo "Paquete de arquitectura i386 ya instalado"
fi

#Clone Cisco necessary devices images
wget -nc -O "${QEMU_DIR}/asav-9-18-1/virtioa.qcow2" "$ASAV9181_LINK" 2>/dev/null
wget -nc -O "${QEMU_DIR}/asav-9-8-3/virtioa.qcow2" "$ASAV983_LINK" 2>/dev/null
wget -nc -O "${QEMU_DIR}/csr1000vng-universalk9.17.03.05/virtioa.qcow2" "$CSR1000_LINK" 2>/dev/null
wget -nc -P "$BIN_DIR" "$SWITCHL2_LINK" 2>/dev/null
wget -nc -P "$BIN_DIR" "$SWITCHL3_LINK" 2>/dev/null

#Fix permissions
/opt/unetlab/wrappers/unl_wrapper -a fixpermissions