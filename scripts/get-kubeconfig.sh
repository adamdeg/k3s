#!/bin/bash
set -e

# Check if required parameters are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <master_ip> <ssh_key_path> <cluster_name>"
    exit 1
fi

MASTER_IP=$1
SSH_KEY_PATH=$2
CLUSTER_NAME=$3
KUBE_DIR="../.kube"

# Create local .kube directory if it doesn't exist
mkdir -p ${KUBE_DIR}

# Get kubeconfig from the master node
scp -o StrictHostKeyChecking=no -i ${SSH_KEY_PATH} root@${MASTER_IP}:/etc/rancher/k3s/k3s.yaml ${KUBE_DIR}/config-${CLUSTER_NAME}

# Update the server address in the kubeconfig
sed -i "s/127.0.0.1/${MASTER_IP}/g" ${KUBE_DIR}/config-${CLUSTER_NAME}

echo "Kubeconfig saved to ${KUBE_DIR}/config-${CLUSTER_NAME}"
echo "Use 'export KUBECONFIG=${KUBE_DIR}/config-${CLUSTER_NAME}' to use this configuration"