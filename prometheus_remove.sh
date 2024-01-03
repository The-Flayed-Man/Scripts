#!/bin/bash

# Script log file
LOG_FILE="/var/log/prometheus_uninstallation.log"

# Function to log messages
log_message() {
    echo "$(date): $1" | tee -a $LOG_FILE
}

log_message "Starting Prometheus and Node Exporter uninstallation script."

# Stopping services
log_message "Stopping Prometheus and Node Exporter services..."
systemctl stop prometheus node_exporter

# Disabling services
log_message "Disabling Prometheus and Node Exporter services..."
systemctl disable prometheus node_exporter

# Removing systemd service files
log_message "Removing systemd service files..."
rm -f /etc/systemd/system/prometheus.service
rm -f /etc/systemd/system/node_exporter.service

# Reloading systemd
log_message "Reloading systemd daemon..."
systemctl daemon-reload

# Removing binaries
log_message "Removing Prometheus and Node Exporter binaries..."
rm -f /usr/local/bin/prometheus
rm -f /usr/local/bin/promtool
rm -f /usr/local/bin/node_exporter

# Removing user
log_message "Removing Prometheus user..."
userdel prometheus

# Removing directories and configuration files
log_message "Removing Prometheus and Node Exporter directories and configuration files..."
rm -rf /etc/prometheus
rm -rf /var/lib/prometheus

log_message "Prometheus and Node Exporter uninstallation complete."