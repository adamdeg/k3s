# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Public SSH key to access the server"
  type        = string
  sensitive   = true
}

variable "server_name" {
  description = "Name of the server to be created"
  type        = string
  default     = "k3s-node"
}

variable "image" {
  description = "Name of the image"
  type        = string
  default     = "ubuntu-24.04"
}

variable "server_type" {
  description = "Type of the server to be created"
  type        = string
  default     = "cx22"
}

variable "location" {
  description = "Location of the server"
  type        = string
  default     = "nbg1"
}
