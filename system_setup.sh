#!/bin/bash

#configuring hostname
read -p "Enter the new hostname: " new_hostname
sudo hostnamectl set-hostname $new_hostname
echo "The new hostname is set to $new_hostname"


# Get the current IP address
old_ip=$(ip addr show dev enp1s0 | awk '/inet / {print $2}' | cut -d/ -f1)

read -p "Enter the new IP address: " new_ip
subnet_mask=24  # Set this to the appropriate value for your network

# Remove the old IP address
sudo ip addr del $old_ip/$subnet_mask dev enp1s0

# Add the new IP address
sudo ip addr add $new_ip/$subnet_mask dev enp1s0

echo "The old IP address $old_ip has been replaced with the new IP address $new_ip on interface enp1s0"

echo "Checking for epel-release to be installed"
# Check if epel-release is installed
if ! rpm -q epel-release &> /dev/null
then
    read -p "epel-release is not installed. Do you want to install it? (yes/no): " answer
    if [ "$answer" == "yes" ]
    then
        sudo yum install epel-release -y
        echo "epel-release has been installed."
    else
        echo "Skipping epel-release installation."
    fi
else
    echo "epel-release is already installed."
fi
