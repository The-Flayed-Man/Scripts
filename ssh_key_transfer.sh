#!/bin/bash

# Check if SSH keys exist
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "SSH keys do not exist."
    echo -n "Would you like to generate SSH keys (y/n)? "
    read answer

    # Generate SSH keys if user's response is 'y'
    if [ "$answer" != "${answer#[Yy]}" ] ;then
        ssh-keygen -t rsa -b 2048
    else
        echo "Exiting without generating SSH keys."
        exit 1
    fi
fi

#Ask for the username
echo -n "Enter the username to copy keys to:"
read username

# Ask for the server IP
echo -n "Enter the server IP or name to copy SSH keys: "
read server

# Copy SSH keys to the server
ssh-copy-id -i ~/.ssh/id_rsa.pub $username@$server

echo "Passwordless SSH has been set up for $server"