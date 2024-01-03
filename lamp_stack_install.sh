#!/bin/bash

# Function to check if a command succeeded
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error occurred in $1"
        exit 1
    fi
}

# Update System
echo "Updating system..."
sudo dnf update -y
check_status "System Update"

# Install Apache
echo "Installing Apache..."
sudo dnf install httpd -y
check_status "Apache Installation"

# Start and enable Apache
echo "Starting and enabling Apache..."
sudo systemctl start httpd
check_status "Apache Start"
sudo systemctl enable httpd
check_status "Apache Enable"

# Adjust firewall settings
echo "Configuring firewall for HTTP and HTTPS..."
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
check_status "Firewall Configuration"

# Install MariaDB (MySQL)
echo "Installing MariaDB..."
sudo dnf install mariadb-server mariadb -y
check_status "MariaDB Installation"

# Start and enable MariaDB
echo "Starting and enabling MariaDB..."
sudo systemctl start mariadb
check_status "MariaDB Start"
sudo systemctl enable mariadb
check_status "MariaDB Enable"

# Secure MariaDB installation
echo "Please follow the on-screen instructions to secure your MariaDB installation:"
sudo mysql_secure_installation
check_status "MariaDB Secure Installation"

# Install PHP and common modules
echo "Installing PHP and common modules..."
sudo dnf install php php-mysqlnd php-fpm php-opcache php-gd php-xml php-mbstring -y
check_status "PHP Installation"

# Restart Apache to load PHP
echo "Restarting Apache to load PHP configuration..."
sudo systemctl restart httpd
check_status "Apache Restart"

echo "LAMP stack installation complete."