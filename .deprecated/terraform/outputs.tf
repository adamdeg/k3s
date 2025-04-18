output "vm_ip" {
  description = "Public IPv4 address of the created VM"
  value       = hcloud_server.ubuntu_vm.ipv4_address
}
