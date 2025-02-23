#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Install K3S (lightweight Kubernetes)
echo "Installing K3S..."
curl -sfL https://get.k3s.io | sh -

# Enable and start K3S service
echo "Enabling and starting K3S service..."
systemctl enable k3s
systemctl start k3s

# Print K3S node status
echo "K3S installation completed. Checking node status..."
kubectl get nodes

# Save the K3S kubeconfig to a readable location
mkdir -p /root/.kube
cp /etc/rancher/k3s/k3s.yaml /root/.kube/config
chown $(whoami):$(whoami) /root/.kube/config
echo "K3S kubeconfig is available at /root/.kube/config"

# Output success message
echo "✅ K3S installation completed successfully!"

