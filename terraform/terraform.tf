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
      version = "0.81.0"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.8.1"
    }
  }
}
