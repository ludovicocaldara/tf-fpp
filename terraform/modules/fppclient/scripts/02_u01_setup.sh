#!/bin/bash

# to avoid empty variables
set -u 
# debugging output for terraform deployment
set -x

# compute OL7.8 uses firewalld, not iptables
systemctl stop firewalld
systemctl disable firewalld

# enable SHH password authentication in the subnet to ease rhpctl remote commands
sed -i /^PasswordAuthentication/d /etc/ssh/sshd_config
cat <<EOF >> /etc/ssh/sshd_config
PasswordAuthentication no
Match address ${vcn_cidr}
    PasswordAuthentication yes
EOF
systemctl reload sshd

# setting fppc password to a default for the lab
echo "FPPll##123" | passwd --stdin opc

## the variables ipv4, port, attachment_type and iqn are replaced by the terraform templating engine
deviceByPath=/dev/disk/by-path/ip-${ipv4}:${port}-${attachment_type}-${iqn}-lun-1 

device=$(readlink -f $deviceByPath)

parted -s -a optimal $device mklabel gpt -- mkpart primary 2048s 100%
sleep 1

# LVM setup
# notice here double-dollar: it's to escape the dollar for the terraform templating engine
pvcreate $${device}1
vgcreate VolGroupU01 $${device}1
lvcreate -y -l 100%FREE -n LogVolU01 VolGroupU01
# Make XFS
mkfs.xfs -f /dev/VolGroupU01/LogVolU01
# Set fstab
UUID=`blkid -s UUID -o value /dev/VolGroupU01/LogVolU01`
mkdir -p /u01

# force variable expansion to exit with error if not there
echo $UUID
cat >> /etc/fstab <<EOF
UUID=$${UUID}  /u01    xfs    defaults,noatime,_netdev      0      2
EOF
# Mount
mount /u01

