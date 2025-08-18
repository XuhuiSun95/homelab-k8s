resource "talos_machine_secrets" "machine_secrets" {}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = local.controlplane_v4
}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

resource "talos_machine_configuration_apply" "controlplane" {
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  for_each                    = local.controlplanes
  node                        = each.value.ipv6ula
  endpoint                    = each.value.ipv4
  config_patches = [
    templatefile("${path.module}/templates/controlplane.yaml.tmpl", {
      release      = var.release,
      certSANs     = [each.value.ipv4, each.value.ipv6, each.value.ipv6ula],
      validSubnets = [each.value.ipv6ula]
    })
  ]

  depends_on = [
    proxmox_virtual_environment_vm.controlplane,
  ]
}

output "talos_machine_configuration_apply" {
  sensitive = true
  value = {
    for k, v in talos_machine_configuration_apply.controlplane : k => v.machine_configuration
  }
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.controlplane_v6ula[0]
  endpoint             = local.controlplane_v4[0]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.controlplane_v6[0]
}