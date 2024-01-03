#!/bin/bash

# Kafka version and download URL
KAFKA_VERSION="3.6.0"
KAFKA_DOWNLOAD_URL="https://dlcdn.apache.org/kafka/${KAFKA_VERSION}/kafka_2.13-${KAFKA_VERSION}.tgz"

# Kafka installation directory
KAFKA_DIR="/opt/kafka"

# Check if this script is already running
if pidof -o %PPID -x "$(basename "$0")"; then
   echo "Another instance of this script is already running."
#   exit 1
fi

# Check if Kafka is already installed
if [ -d "$KAFKA_DIR" ]; then
    echo "Kafka appears to be already installed in $KAFKA_DIR."
#    exit 1
fi

# Check if Java is installed
if ! type java > /dev/null 2>&1; then
    echo "Java is not installed. Installing Java..."
    dnf install java-11-openjdk -y
#    exit 0
fi

# Create Kafka directory
mkdir -p $KAFKA_DIR

# Download Kafka
echo "Downloading Kafka..."
wget -q $KAFKA_DOWNLOAD_URL -O /tmp/kafka.tgz

# Extract Kafka
echo "Extracting Kafka..."
tar -xzf /tmp/kafka.tgz -C $KAFKA_DIR --strip-components=1

# Clean up the downloaded file
rm /tmp/kafka.tgz

# Set up environment variables
echo "export KAFKA_HOME=$KAFKA_DIR" >> ~/.bash_profile
echo "export PATH=\$PATH:\$KAFKA_HOME/bin" >> ~/.bash_profile
source ~/.bash_profile

echo "Apache Kafka installed successfully."
echo "You can start Kafka using the kafka-server-start.sh script located in $KAFKA_DIR/bin"
