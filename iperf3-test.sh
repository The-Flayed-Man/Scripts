#!/bin/bash

read -p "Enter the iperf3 server IP address: " SERVER_IP
read -p "Enter the the amount of time you would like to run the test: " DURATION
read -p "Enter how many parallel connections: " PARALLEL_CONNECTIONS

echo "Starting iperf3 client to connect to server $SERVER_IP..."
iperf3 -c $SERVER_IP -t $DURATION -P $PARALLEL_CONNECTIONS

echo "iperf3 test completed."