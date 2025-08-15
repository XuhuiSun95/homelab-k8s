provider "proxmox" {
  endpoint = var.virtual_environment_endpoint
  insecure = true

  api_token = var.virtual_environment_api_token

  ssh {
    agent    = true
    username = var.virtual_environment_ssh_username
  }
}
