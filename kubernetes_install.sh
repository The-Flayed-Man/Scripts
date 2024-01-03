#!/bin/bash

# Update the system
echo "Updating the system..."
sudo dnf update -y

# Install required packages
echo "Installing required packages..."
sudo dnf install -y yum-utils device-mapper-persistent-data lvm2

# Add the Docker repository
echo "Adding Docker repository..."
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker CE
echo "Installing Docker..."
sudo dnf install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker
echo "Starting and enabling Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# Disable SELinux (Kubernetes suggests this for compatibility)
echo "Disabling SELinux..."
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Add the Kubernetes repository
echo "Adding Kubernetes repository..."
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Install Kubernetes
echo "Installing Kubernetes components..."
sudo dnf install -y kubelet kubeadm kubectl

# Enable kubelet
echo "Enabling kubelet..."
sudo systemctl enable --now kubelet

#Set Firewalld rules
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --reload

mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl restart containerd

echo "Kubernetes installation is complete."