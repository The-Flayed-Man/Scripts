#!/bin/bash

# Array of services to check
services=("jenkins" "prometheus" "grafana-server" "sshd")

# Function to check the status of a service and print it
print_service_status() {
    local service=$1
    local status
    if systemctl is-active --quiet $service; then
        status="Active"
    else
        status="Down"
    fi
    printf "%-20s %-15s\n" "$service" "$status"
}

# Print the header for the table
echo -e "\nService Status:"
printf "%-20s %-15s\n" "Service" "Status"

# Main loop to check each service
for service in "${services[@]}"; do
    print_service_status $service
done
