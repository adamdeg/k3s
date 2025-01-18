resource "hcloud_ssh_key" "default" {
  name       = "github-action-key"
  public_key = var.ssh_public_key
}

resource "hcloud_server" "ubuntu_vm" {
  name        = var.server_name
  image       = var.image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]
}
