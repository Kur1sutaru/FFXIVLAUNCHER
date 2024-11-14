#!/bin/bash

# Automatically detect the primary network interface
DEVICE_NAME=$(ip route | grep default | awk '{print $5}')

# Ensure DEVICE_NAME is detected
if [ -z "$DEVICE_NAME" ]; then
    echo "Error: Could not determine the network interface."
    exit 1
fi

# Check if LOCAL is true for applying NAT rules
if [ -z "$LOCAL" ] || [ "$LOCAL" = "true" ]; then
    # Verify if the network interface exists
    if ip addr show "$DEVICE_NAME" &>/dev/null; then
        for ip_addr in $(ip addr show "$DEVICE_NAME" | grep "inet\b" | awk '{print $2}'); do
            echo "Adding NAT rule for IP: $ip_addr on device: $DEVICE_NAME"
            iptables -t nat -A POSTROUTING -s "$ip_addr" -o "$DEVICE_NAME" -j MASQUERADE
        done
    else
        echo "Error: Network device $DEVICE_NAME not found!"
        exit 1
    fi
fi

# Download the ffxiv_dx11.exe file
echo "Downloading ffxiv_dx11.exe..."
if ! curl -L -o ffxiv_dx11.exe https://raw.githubusercontent.com/bankjaneo/XivMitmDocker/main/app/ffxiv_dx11.exe; then
    echo "Error: Failed to download ffxiv_dx11.exe"
    exit 1
fi

# Start latency mitigation using mitigate.py
echo "Starting latency mitigation..."
if ! curl -s https://raw.githubusercontent.com/Soreepeong/XivMitmLatencyMitigator/main/mitigate.py | python; then
    echo "Error: Failed to start latency mitigation"
    exit 1
fi

echo "Script completed successfully."

