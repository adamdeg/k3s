# Automated K3S Cluster Deployment on Hetzner Cloud

This project provides an automated solution for deploying a K3S Kubernetes cluster on Hetzner Cloud using GitHub Actions, Terraform, and Ansible.

## Features

- Fully automated deployment via GitHub Actions
- Scalable architecture (easily add more master or worker nodes)
- Private network configuration for node communication
- Security with proper firewall rules
- Kubeconfig retrieval and storage as GitHub artifact

## Prerequisites

Before using this project, you need:

1. A Hetzner Cloud account with an API token
2. An SSH key pair for server access
3. A GitHub repository with the required secrets configured

## Repository Structure

```
project-root/
├── .github/
│   └── workflows/
│       └── deploy.yml         # GitHub Actions workflow
├── terraform/                 # Terraform configuration
│   ├── main.tf                # Main Terraform configuration
│   ├── variables.tf           # Variables definition
│   ├── outputs.tf             # Output values
│   ├── providers.tf           # Provider configuration
│   └── versions.tf            # Terraform version constraints
├── ansible/                   # Ansible configuration
│   ├── inventory/
│   │   └── hosts.ini.tmpl     # Ansible inventory template
│   ├── playbooks/
│   │   ├── main.yml           # Main playbook
│   │   ├── master.yml         # Master node playbook
│   │   └── worker.yml         # Worker node playbook
│   ├── roles/                 # Ansible roles
│   │   ├── common/            # Common settings
│   │   ├── k3s-master/        # K3S master node setup
│   │   └── k3s-worker/        # K3S worker node setup
│   └── ansible.cfg            # Ansible configuration
├── scripts/                   # Helper scripts
│   ├── generate-inventory.sh  # Generate Ansible inventory
│   └── get-kubeconfig.sh      # Retrieve kubeconfig
└── README.md                  # Project documentation
```

## Setup Instructions

### 1. Repository Setup

1. Clone this repository or create a new one with the provided files.
2. Add the following secrets to your GitHub repository:
   - `HCLOUD_TOKEN`: Your Hetzner Cloud API token
   - `SSH_PRIVATE_KEY`: Your SSH private key (content of the private key file)
   - `SSH_PUBLIC_KEY`: Your SSH public key (content of the public key file)

### 2. Deployment

To deploy the K3S cluster:

1. Go to the "Actions" tab in your GitHub repository
2. Select the "Deploy K3S Cluster on Hetzner Cloud" workflow
3. Click "Run workflow"
4. Configure the deployment:
   - Action: `apply` (to create the cluster)
   - Number of master nodes: Enter the desired number (default: 1)
   - Number of worker nodes: Enter the desired number (default: 2)
5. Click "Run workflow" to start the deployment

The workflow will:
- Provision the specified infrastructure on Hetzner Cloud
- Install and configure K3S on all nodes
- Create a secure network between nodes
- Set up proper firewall rules
- Retrieve the kubeconfig file for cluster access

### 3. Accessing Your Cluster

After successful deployment, the workflow will:
1. Output the cluster information (node IPs, API endpoint)
2. Save the kubeconfig as a GitHub artifact

To use the kubeconfig:
1. Download the kubeconfig artifact from the GitHub Actions run
2. Set the `KUBECONFIG` environment variable to point to the downloaded file:
   ```bash
   export KUBECONFIG=/path/to/downloaded/config-k3s-cluster
   ```
3. Use kubectl to interact with your cluster:
   ```bash
   kubectl get nodes
   ```

### 4. Scaling the Cluster

To add more nodes to your cluster:
1. Run the workflow again with increased values for master or worker nodes
2. The workflow will add the new nodes while preserving the existing ones

### 5. Destroying the Cluster

To destroy the cluster and clean up all resources:
1. Run the workflow with the "Action" set to `destroy`
2. The workflow will remove all created resources from Hetzner Cloud

## Customization

### Changing Node Sizes

Edit the `terraform/variables.tf` file to change default server types:
- `master_server_type`: Server type for master nodes (default: cx21)
- `worker_server_type`: Server type for worker nodes (default: cx21)

### Modifying Network Settings

Edit the `terraform/variables.tf` file to change network configuration:
- `network_ip_range`: IP range for the private network
- `master_ip_range`: IP range for master nodes
- `worker_ip_range`: IP range for worker nodes

### Changing K3S Version

Edit the `ansible/inventory/hosts.ini.tmpl` file to change the K3S version:
- `k3s_version`: Set to your desired K3S version

## Troubleshooting

### Common Issues

1. **SSH Connection Issues**:
   - Ensure your SSH keys are correctly set up as GitHub secrets
   - Check if the private key format is correct (including all lines)

2. **Terraform State Issues**:
   - The Terraform state is stored locally in the GitHub runner
   - For persistent state, consider configuring a remote backend

3. **Ansible Playbook Failures**:
   - Check the GitHub Actions logs for detailed error messages
   - Try running the scripts manually with the `-vvv` flag for verbose output

### Manual Intervention

If you need to manually interact with the cluster:
1. SSH into the master node using your private key:
   ```bash
   ssh -i /path/to/private/key root@<master-ip>
   ```
2. Check the K3S service status:
   ```bash
   systemctl status k3s
   ```
3. View logs:
   ```bash
   journalctl -u k3s
   ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.