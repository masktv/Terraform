#!/bin/bash

# Update package list
apt-get update -y

# Install EFS mount helper (amazon-efs-utils)
apt-get install -y amazon-efs-utils

# Add EFS DNS entry to /etc/fstab
echo "${efs_dns}:/ /var/www/html efs defaults,_netdev 0 0" >> /etc/fstab

# Mount all filesystems
mount -a

