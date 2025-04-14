#!/bin/bash

# Update package list
apt-get update -y

# Install EFS mount helper (amazon-efs-utils)
apt install -y nfs-common

# Add EFS DNS entry to /etc/fstab
#echo "${efs_dns}:/ /var/www/html nfs4 defaults,_netdev 0 0" >> /etc/fstab
echo "${efs_dns}:/ /var/www/html nfs4 nfsvers=4.1,_netdev 0 0" >> /etc/fstab

# Mount all filesystems
mount -a

