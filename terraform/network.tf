locals {
  zones = [for k, v in var.controlplane : k]

  gwv4 = cidrhost(var.vpc_cidr[0], 1)
}
