#!/bin/bash

set -e

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

echo "Installing K3S..."
curl -sfL https://get.k3s.io | sh -

echo "Enabling and starting K3S service..."
systemctl enable k3s
systemctl start k3s

echo "K3S installation completed. Checking node status..."
kubectl get nodes

mkdir -p /root/.kube
cp /etc/rancher/k3s/k3s.yaml /root/.kube/config
chown $(whoami):$(whoami) /root/.kube/config
echo "K3S kubeconfig is available at /root/.kube/config"

echo "✅ K3S installation completed successfully!"
