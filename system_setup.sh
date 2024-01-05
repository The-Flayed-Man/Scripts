#!/bin/bash

#configuring hostname
read -p "Enter the new hostname: " new_hostname
sudo hostnamectl set-hostname $new_hostname
echo "The new hostname is set to $new_hostname"

#CHANGING IPADDRESS
# Get the current IP address
old_ip=$(ip addr show dev enp1s0 | awk '/inet / {print $2}' | cut -d/ -f1)

read -p "Enter the new IP address: " new_ip
subnet_mask=24  # Set this to the appropriate value for your network

# Remove the old IP address
sudo ip addr del $old_ip/$subnet_mask dev enp1s0

# Add the new IP address
sudo ip addr add $new_ip/$subnet_mask dev enp1s0

echo "The old IP address $old_ip has been replaced with the new IP address $new_ip on interface enp1s0"

#DNF CONFIG
DNF_CONF="/etc/dnf/dnf.conf"

# Function to add a configuration if it doesn't exist
add_config_if_not_exists() {
    local config="$1"
    local file="$2"
    if ! grep -q "^$config" "$file"; then
        echo "$config" >> "$file"
        echo "Added $config to $file"
    else
        echo "$config already exists in $file"
    fi
}

# Check and add configurations
add_config_if_not_exists "fastestmirror=True" "$DNF_CONF"
add_config_if_not_exists "max_parallel_downloads=10" "$DNF_CONF"

#CHECKING FOR EPEL-RELEASE
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


# ADD Alias
echo "Add alias to server"
# Function to ask user for new alias
ask_for_alias() {
    read -p "Enter the alias name: " alias_name
    read -p "Enter the command for the alias: " command
    echo "alias $alias_name='$command'"
}

# Array to hold aliases
declare -a aliases

# Loop to collect aliases
while true; do
    # Ask for an alias
    new_alias=$(ask_for_alias)
    
    # Add to the array
    aliases+=("$new_alias")
    
    # Ask if user wants to add another
    read -p "Do you want to add another alias? (y/n) " answer
    if [ "$answer" != "y" ]; then
        break
    fi
done

# Display the aliases and ask for confirmation
echo "You have added the following aliases:"
printf "%s\n" "${aliases[@]}"
read -p "Are you sure you want to add these to .bashrc? (y/n) " confirm

if [ "$confirm" == "y" ]; then
    # Append the aliases to .bashrc and reload it
    for alias in "${aliases[@]}"; do
        echo "$alias" >> ~/.bashrc
    done
    source ~/.bashrc
    echo "Aliases added and .bashrc reloaded."
else
    echo "No aliases were added."
fi