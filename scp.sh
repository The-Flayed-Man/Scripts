#!/bin/bash

# Prompt the user for the remote username
echo "Please enter the username:"
read username

# Prompt the user for the remote IP address
echo "Please enter the IP addresses (comma-separated):"
read ip_addresses

# Prompt the user for the remote directory
echo "Please enter the path for file on the remote directory:"
read remote_directory

# Prompt the user for the local file to be copied
echo "Please enter the file path of the files (comma-separated):"
read local_files

# Convert the comma-separated IP addresses into an array
IFS=',' read -ra ADDR <<< "$ip_addresses"
IFS=',' read -ra FILES <<< "$local_files"

# Use scp to copy the file to the remote server
for ip_address in "${ADDR[@]}"; do
    for local_file in "${FILES[@]}"; do

        local_file=$(echo $local_file | xargs)
        
	filename=$(basename ${local_file})    
    
        scp -r ${local_file} ${username}@${ip_address}:${remote_directory}

# Log into the server and list the transferred file
        echo "Listing the transferred file on server ${ip_address}:"
        ssh ${username}@${ip_address} "ls -lh ${remote_directory}/${filename}" 
    done
done
