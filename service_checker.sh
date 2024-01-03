#!/bin/bash

# Array of services to check
services=("jenkins" "prometheus" "grafana-server" "sshd")

# Initialize an associative array to hold service info
declare -A service_info

# Function to check the status of a service
check_service() {
    local service=$1
    if systemctl is-active --quiet $service; then
        service_info[$service,initial]="Active"
        ask_to_stop_service $service
    else
        service_info[$service,initial]="Down"
        ask_to_start_service $service
    fi
}

# Function to stop a service
stop_service() {
    local service=$1
    echo "Stopping $service..."
    sudo systemctl stop $service
    echo "$service has been stopped."
    service_info[$service,action]="Stopped"
}

# Function to start a service
start_service() {
    local service=$1
    echo "Starting $service..."
    sudo systemctl start $service
    echo "$service has been started."
    service_info[$service,action]="Started"
}

# Function to ask to stop a service
ask_to_stop_service() {
    local service=$1
    read -p "Do you want to stop $service? (yes/no): " stop_answer
    case $stop_answer in
        [Yy]* ) stop_service $service;;
        [Nn]* ) service_info[$service,action]="No action";;
        * ) echo "Invalid response."; service_info[$service,action]="Invalid response";;
    esac
}

# Function to ask to start a service
ask_to_start_service() {
    local service=$1
    read -p "Do you want to start $service? (yes/no): " start_answer
    case $start_answer in
        [Yy]* ) start_service $service;;
        [Nn]* ) service_info[$service,action]="No action";;
        * ) echo "Invalid response."; service_info[$service,action]="Invalid response";;
    esac
}

# Main loop to check each service
for service in "${services[@]}"; do
    check_service $service
    # Check final status of the service
    if systemctl is-active --quiet $service; then
        service_info[$service,final]="Active"
    else
        service_info[$service,final]="Down"
    fi
done

# Print summary table
echo -e "\nSummary Table:"
printf "%-20s %-15s %-15s %-15s\n" "Service" "Initial Status" "Action Taken" "Final Status"
for service in "${services[@]}"; do
    printf "%-20s %-15s %-15s %-15s\n" "$service" "${service_info[$service,initial]}" "${service_info[$service,action]}" "${service_info[$service,final]}"
done
