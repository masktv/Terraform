#!/bin/bash

# Update package list
apt-get update -y

# Install EFS mount helper (amazon-efs-utils)
apt install nfs-common -y

# Add EFS DNS entry to /etc/fstab
echo "${efs_dns}:/ /var/www/html nfs4 defaults,_netdev 0 0" >> /etc/fstab
echo "${log_dns}:/ /var/log/apache2 nfs4 defaults,_netdev 0 0" >> /etc/fstab

# reload daemon 
systemctl daemon-reload
sleep 60
# Mount all filesystems
mount -a

