variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for server access"
  type        = string
}

variable "ssh_private_key" {
  description = "SSH private key content"
  type        = string
  sensitive   = true
  default     = "" 
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key for Ansible"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "cluster_name" {
  description = "Name of the K3S cluster"
  type        = string
  default     = "k3s-cluster"
}

variable "master_node_count" {
  description = "Number of master nodes"
  type        = number
  default     = 1
}

variable "worker_node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "master_server_type" {
  description = "Hetzner Cloud server type for master nodes"
  type        = string
  default     = "cx22"  # 2 vCPU, 4 GB RAM
}

variable "worker_server_type" {
  description = "Hetzner Cloud server type for worker nodes"
  type        = string
  default     = "cx22"  # 2 vCPU, 4 GB RAM
}

variable "server_location" {
  description = "Hetzner Cloud server location"
  type        = string
  default     = "nbg1"  # Nuremberg, Germany
}

variable "os_image" {
  description = "Operating system image"
  type        = string
  default     = "ubuntu-24.04"
}

variable "network_zone" {
  description = "Network zone for the private network"
  type        = string
  default     = "eu-central"
}

variable "network_ip_range" {
  description = "IP range for the private network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "master_ip_range" {
  description = "IP range for master nodes"
  type        = string
  default     = "10.0.1.0/24"
}

variable "worker_ip_range" {
  description = "IP range for worker nodes"
  type        = string
  default     = "10.0.2.0/24"
}