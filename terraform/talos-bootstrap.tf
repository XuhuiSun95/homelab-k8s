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
  node                        = each.value.ipv4
  config_patches = [
    templatefile("${path.module}/templates/controlplane.yaml.tmpl", {
      installer_image  = data.talos_image_factory_urls.talos_image.urls.installer
      certSANs         = [each.value.ipv4]
      validSubnets     = [each.value.ipv4]
      cluster_vip      = var.cluster_vip
      cluster_vip_vlan = var.cluster_vip_vlan
      cilium_template  = indent(8, chomp(data.helm_template.cilium.manifest))
    })
  ]

  depends_on = [
    proxmox_virtual_environment_vm.controlplane,
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.controlplane_v4[0]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.controlplane_v4[0]
}