variable "virtual_environment_endpoint" {
  description = "The endpoint of the Proxmox VE API"
  type        = string
}

variable "virtual_environment_api_token" {
  description = "The API token for the Proxmox VE API"
  type        = string
  sensitive   = true
}

variable "virtual_environment_ssh_username" {
  description = "The username for the Proxmox VE SSH"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Proxmox Cluster Name"
  type        = string
  default     = "region-1"
}

variable "network_shift" {
  description = "Network number shift"
  type        = number
  default     = 8
}

variable "vpc_cidr" {
  description = "Local proxmox subnets"
  type        = list(string)
  default     = ["172.16.0.0/24", "fd60:172:16::/64"]
}

variable "nodes" {
  description = "Proxmox nodes properties"
  type        = map(any)
  default = {
    "hvm-1" = {
      storage = "data",
      gw4     = "1.1.0.1",
      gw6     = "2001:1:2:1::64",
      vlan_id = 10,
      trunks  = "10;110",
    },
    "hvm-2" = {
      storage = "data",
      gw4     = "1.1.0.2",
      gw6     = "2001:1:2:2::64",
      vlan_id = 20,
      trunks  = "20;120",
    },
  }
}

variable "release" {
  type        = string
  description = "The version of the Talos image"
  default     = "1.10.6"
}

variable "controlplane" {
  description = "Property of controlplane"
  type        = map(any)
  default = {
    "hvm-1" = {
      id    = 10010
      count = 0,
      cpu   = 4,
      mem   = 6144,
    },
  }
}