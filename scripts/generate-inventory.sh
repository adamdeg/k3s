#!/bin/bash
set -e

# This script is a backup in case the Terraform-generated inventory fails
# It reads the Terraform state to generate an Ansible inventory

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPT_DIR}/../terraform"

# Get master and worker nodes from Terraform output
MASTER_IPS=$(terraform output -json master_ips)
WORKER_IPS=$(terraform output -json worker_ips)

# Create inventory file
INVENTORY_FILE="../ansible/inventory/hosts.ini"
mkdir -p $(dirname ${INVENTORY_FILE})

echo "[masters]" > ${INVENTORY_FILE}
echo "${MASTER_IPS}" | jq -r 'to_entries[] | "\(.key) ansible_host=\(.value) ansible_user=root"' >> ${INVENTORY_FILE}

echo "" >> ${INVENTORY_FILE}
echo "[workers]" >> ${INVENTORY_FILE}
echo "${WORKER_IPS}" | jq -r 'to_entries[] | "\(.key) ansible_host=\(.value) ansible_user=root"' >> ${INVENTORY_FILE}

echo "" >> ${INVENTORY_FILE}
echo "[k3s_cluster:children]" >> ${INVENTORY_FILE}
echo "masters" >> ${INVENTORY_FILE}
echo "workers" >> ${INVENTORY_FILE}

echo "" >> ${INVENTORY_FILE}
echo "[k3s_cluster:vars]" >> ${INVENTORY_FILE}
echo "ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> ${INVENTORY_FILE}
echo "k3s_version=v1.26.1+k3s1" >> ${INVENTORY_FILE}
echo "systemd_dir=/etc/systemd/system" >> ${INVENTORY_FILE}

echo "Inventory file generated at ${INVENTORY_FILE}"