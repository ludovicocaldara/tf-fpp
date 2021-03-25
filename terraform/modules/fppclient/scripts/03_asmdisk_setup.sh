#!/bin/bash

# to avoid empty variables
set -u 
# debugging output for terraform deployment
set -x

# add group asmadmin and affect it to oracle
# (oracle user should be there already)
groupadd asmadmin
usermod -a -G asmadmin oracle

## the variables ipv4, port, attachment_type and iqn are replaced by the terraform templating engine
deviceByPath=/dev/disk/by-path/ip-${ipv4}:${port}-${attachment_type}-${iqn}-lun-1 

device=$(readlink -f $deviceByPath)

parted -s -a optimal $device mklabel gpt -- mkpart primary 2048s 100%

sleep 1

scsiid=`/usr/lib/udev/scsi_id -g -u -d $${device}1`
echo "KERNEL==\"sd?1\", SUBSYSTEM==\"block\", PROGRAM==\"/usr/lib/udev/scsi_id -g -u -d /dev/\$parent\", RESULT==\"$scsiid\", SYMLINK+=\"oracleasm/asm-disk1\", OWNER=\"oracle\", GROUP=\"asmadmin\", MODE=\"0660\"" >> /etc/udev/rules.d/70-persistent-disk.rules

/sbin/partprobe $${device}1
sleep 2
/sbin/udevadm control --reload-rules
sleep 2
/sbin/partprobe $${device}1
sleep 2
/sbin/udevadm control --reload-rules

