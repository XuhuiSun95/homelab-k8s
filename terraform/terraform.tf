terraform {
  cloud {
    organization = "ericsun1995"
    workspaces {
      name = "homelab-k8s"
    }
  }

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.113.1"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0"
    }
  }
}
