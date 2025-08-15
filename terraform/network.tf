locals {
  zones = [for k, v in var.controlplane : k]

  gwv4 = cidrhost(var.vpc_cidr[0], 1)
  gwv6 = cidrhost(var.vpc_cidr[1], 1)
}
