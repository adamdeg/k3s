output "master_ips" {
  description = "Public IP addresses of master nodes"
  value       = {
    for node in hcloud_server.k3s_master : node.name => node.ipv4_address
  }
}

output "worker_ips" {
  description = "Public IP addresses of worker nodes"
  value       = {
    for node in hcloud_server.k3s_worker : node.name => node.ipv4_address
  }
}

output "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  value       = "${path.module}/../.kube/config-${var.cluster_name}"
}

output "k3s_api_endpoint" {
  description = "K3S API endpoint"
  value       = "https://${hcloud_server.k3s_master[0].ipv4_address}:6443"
}

output "k3s_cluster_size" {
  description = "Total size of the K3S cluster"
  value       = "${var.master_node_count + var.worker_node_count} nodes (${var.master_node_count} masters, ${var.worker_node_count} workers)"
}