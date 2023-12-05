#!/bin/bash

# Backup existing SSH config file
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Function to modify SSH configuration using sed
modify_ssh_config() {
    local setting="$1"
    local value="$2"
    local config_file="/etc/ssh/sshd_config"

    # Check if the setting exists and modify it, otherwise append it
    if grep -q "^#\?$setting" "$config_file"; then
        sed -i "s/^#\?$setting.*/$setting $value/" "$config_file"
    else
        echo "$setting $value" >> "$config_file"
    fi
}

# Disable root login
modify_ssh_config "PermitRootLogin" "no"

# Disable password authentication, use keys instead
modify_ssh_config "PasswordAuthentication" "no"

# Change default SSH port (e.g., to 22)
modify_ssh_config "Port" "22"

# Limit user login (optional, replace 'username' with actual username)
modify_ssh_config "AllowUsers" "flayed-man" "root"

# Disable empty passwords
modify_ssh_config "PermitEmptyPasswords" "no"

# Enable Public Key Authentication
modify_ssh_config "PubkeyAuthentication" "yes"

# Advanced settings (ciphers, MACs, KexAlgorithms)
modify_ssh_config "Ciphers" "aes256-ctr,aes192-ctr,aes128-ctr"
modify_ssh_config "MACs" "hmac-sha2-512,hmac-sha2-256"
modify_ssh_config "KexAlgorithms" "diffie-hellman-group-exchange-sha256"

# Set SSH banner (replace '/path/to/banner_file' with the actual file path)
modify_ssh_config "Banner" "/etc/issue"

#Set the max startups
modify_ssh_config "MaxStartups" "10:30:100"

#Set the ClientAliveInterval
modify_ssh_config "ClientAliveInterval" "180"

#Set the ClientAliveCountMax
modify_ssh_config "ClientAliveCountMax" "3"

#Set  MaxAuthTries
modify_ssh_config "MaxAuthTries" "3"

#Set X11Forwarding
modify_ssh_config "X11Forwarding" "no"

#Set MaxSessions
modify_ssh_config "MaxSessions" "10"



# Restart SSH service to apply changes
systemctl restart sshd

systemctl is-enabled sshd

systemctl is-active sshd

echo "SSH has been secured and hardened."
