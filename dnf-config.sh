#!/bin/bash

# Path to the dnf configuration file
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