#!/bin/bash

# Function to check the success of previous command
check_success() {
    if [ $? -ne 0 ]; then
        echo "$1"  # Display error message
        exit 1      # Exit script with error
    fi
}

# Create Jenkins user if it doesn't exist
if id "jenkins" &>/dev/null; then
    echo "Jenkins user already exists."
else
    echo "Creating Jenkins user..."
    useradd jenkins
    check_success "Failed to create Jenkins user."
fi

# Check and Install Java (OpenJDK 11)
if type -p java; then
    echo "Java is already installed."
else
    echo "Installing Java..."
    dnf install -y -q java-11-openjdk
    check_success "Failed to install Java."
fi

# Check and Add Jenkins Repository
if [ ! -f /etc/yum.repos.d/jenkins.repo ]; then
    echo "Adding Jenkins Repository..."
    curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | tee /etc/yum.repos.d/jenkins.repo
    check_success "Failed to add Jenkins repository."

    # Manually importing Jenkins key
    echo "Importing Jenkins key..."
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    check_success "Failed to import Jenkins key."
else
    echo "Jenkins repository is already added."
fi

# Check and Install Jenkins
if ! dnf list installed jenkins &>/dev/null; then
    echo "Installing Jenkins..."
    # Installing Jenkins with skipping GPG check
    dnf install -y -q --nogpgcheck jenkins
    check_success "Failed to install Jenkins."
else
    echo "Jenkins is already installed."
fi

# Start and Enable Jenkins Service
echo "Starting Jenkins..."
systemctl start jenkins
check_success "Failed to start Jenkins service."
echo "Jenkins service started successfully."

systemctl enable jenkins
check_success "Failed to enable Jenkins service."
echo "Jenkins service enabled to start on boot successfully."

# Generate SSH Key for Jenkins User
echo "Generating SSH key for Jenkins user..."

# Ensure the .ssh directory exists
sudo -u jenkins mkdir -p /var/lib/jenkins/.ssh
check_success "Failed to create .ssh directory for Jenkins user."

# Set proper permissions for the .ssh directory
sudo -u jenkins chmod 700 /var/lib/jenkins/.ssh
check_success "Failed to set permissions for .ssh directory."

# Generate SSH Key for Jenkins User
if [ ! -f /var/lib/jenkins/.ssh/id_rsa ]; then
    # Generate the SSH key
    sudo -u jenkins ssh-keygen -t rsa -b 4096 -N "" -f /var/lib/jenkins/.ssh/id_rsa
    if [ $? -ne 0 ]; then
        echo "Failed to generate SSH key for Jenkins user."
        exit 1
    fi
    echo "SSH key for Jenkins user generated successfully."
else
    echo "SSH key for Jenkins user already exists. Skipping generation."
fi

# Get the primary IP address of the server
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo "Jenkins Installation Complete."
echo "You can access Jenkins at http://$IP_ADDRESS:8080"
# Display the initial admin password for Jenkins
if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    echo "Initial Admin Password for Jenkins:"
    cat /var/lib/jenkins/secrets/initialAdminPassword
else
    echo "Initial Admin Password not found. You may need to check the Jenkins installation."
fi
