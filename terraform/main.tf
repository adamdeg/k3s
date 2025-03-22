# SSH key
resource "hcloud_ssh_key" "k3s_key" {
  name       = "${var.cluster_name}-key"
  public_key = var.ssh_public_key
}

# Private network
resource "hcloud_network" "k3s_network" {
  name     = "${var.cluster_name}-network"
  ip_range = var.network_ip_range
}

# Network subnet for the cluster
resource "hcloud_network_subnet" "k3s_subnet" {
  network_id   = hcloud_network.k3s_network.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = var.network_ip_range
}

# Firewall for the cluster
resource "hcloud_firewall" "k3s_firewall" {
  name = "${var.cluster_name}-firewall"

  # Allow SSH
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # Allow HTTPS (for K3S API server)
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "6443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # Allow ICMP (ping)
  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

# Master nodes
resource "hcloud_server" "k3s_master" {
  count       = var.master_node_count
  name        = "${var.cluster_name}-master-${count.index + 1}"
  server_type = var.master_server_type
  image       = var.os_image
  location    = var.server_location
  ssh_keys    = [hcloud_ssh_key.k3s_key.id]
  firewall_ids = [hcloud_firewall.k3s_firewall.id]
  
  network {
    network_id = hcloud_network.k3s_network.id
    ip         = cidrhost(var.master_ip_range, count.index + 10)
  }

  depends_on = [
    hcloud_network_subnet.k3s_subnet
  ]

  # Wait for cloud-init to complete
  provisioner "remote-exec" {
    inline = ["cloud-init status --wait"]
    
    connection {
      type        = "ssh"
      user        = "root"
      private_key = file(var.ssh_private_key_path)
      host        = self.ipv4_address
    }
  }
}

# Worker nodes
resource "hcloud_server" "k3s_worker" {
  count       = var.worker_node_count
  name        = "${var.cluster_name}-worker-${count.index + 1}"
  server_type = var.worker_server_type
  image       = var.os_image
  location    = var.server_location
  ssh_keys    = [hcloud_ssh_key.k3s_key.id]
  firewall_ids = [hcloud_firewall.k3s_firewall.id]
  
  network {
    network_id = hcloud_network.k3s_network.id
    ip         = cidrhost(var.worker_ip_range, count.index + 10)
  }

  depends_on = [
    hcloud_network_subnet.k3s_subnet
  ]

  # Wait for cloud-init to complete
  provisioner "remote-exec" {
    inline = ["cloud-init status --wait"]
    
    connection {
      type        = "ssh"
      user        = "root"
      private_key = file(var.ssh_private_key_path)
      host        = self.ipv4_address
    }
  }
}

# Generate Ansible inventory file
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../ansible/inventory/hosts.ini.tmpl", {
    master_nodes = [
      for node in hcloud_server.k3s_master : {
        name = node.name
        ip   = node.ipv4_address
      }
    ]
    worker_nodes = [
      for node in hcloud_server.k3s_worker : {
        name = node.name
        ip   = node.ipv4_address
      }
    ]
  })
  filename = "${path.module}/../ansible/inventory/hosts.ini"
}

# Run Ansible playbook after infrastructure is created
resource "null_resource" "run_ansible" {
  depends_on = [
    hcloud_server.k3s_master,
    hcloud_server.k3s_worker,
    local_file.ansible_inventory
  ]

  # Trigger Ansible run when infrastructure changes
  triggers = {
    master_ips = join(",", [for node in hcloud_server.k3s_master : node.ipv4_address])
    worker_ips = join(",", [for node in hcloud_server.k3s_worker : node.ipv4_address])
  }

  # Run Ansible playbook
  provisioner "local-exec" {
    command = "cd ${path.module}/../ansible && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/hosts.ini playbooks/main.yml"
  }
}

# Get the kubeconfig file from the first master node
resource "null_resource" "get_kubeconfig" {
  depends_on = [
    null_resource.run_ansible
  ]

  # Run script to get kubeconfig
  provisioner "local-exec" {
    command = "${path.module}/../scripts/get-kubeconfig.sh ${hcloud_server.k3s_master[0].ipv4_address} ${var.ssh_private_key_path} ${var.cluster_name}"
  }
}