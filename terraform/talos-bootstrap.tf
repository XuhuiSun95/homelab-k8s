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

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets

  config_patches = [
    templatefile("${path.module}/templates/worker.yaml.tmpl", {
      validSubnets    = [var.vpc_cidr[0]]
      installer_image = data.talos_image_factory_urls.talos_image.urls.installer
    })
  ]
}

resource "talos_machine_configuration_apply" "controlplane" {
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  for_each                    = local.controlplanes
  node                        = each.value.ipv4
  config_patches = [
    templatefile("${path.module}/templates/controlplane.yaml.tmpl", {
      installer_image = data.talos_image_factory_urls.talos_image.urls.installer
      validSubnets    = [each.value.ipv4]
      proxmox-ccm-clusters = yamlencode({
        "clusters" : [{
          "url" : "${var.virtual_environment_endpoint}/api2/json"
          "insecure" : true
          "token_id" : split("=", proxmox_virtual_environment_user_token.ccm.value)[0]
          "token_secret" : split("=", proxmox_virtual_environment_user_token.ccm.value)[1]
          "region" : var.region
        }]
      })
      proxmox-csi-clusters = yamlencode({
        "clusters" : [{
          "url" : "${var.virtual_environment_endpoint}/api2/json"
          "insecure" : true
          "token_id" : split("=", proxmox_virtual_environment_user_token.csi.value)[0]
          "token_secret" : split("=", proxmox_virtual_environment_user_token.csi.value)[1]
          "region" : var.region
        }]
      })
      proxmox-karpenter-clusters = yamlencode({
        "clusters" : [{
          "url" : "${var.virtual_environment_endpoint}/api2/json"
          "insecure" : true
          "token_id" : split("=", proxmox_virtual_environment_user_token.karpenter.value)[0]
          "token_secret" : split("=", proxmox_virtual_environment_user_token.karpenter.value)[1]
          "region" : var.region
        }]
      })
      proxmox-karpenter-template = data.talos_machine_configuration.worker.machine_configuration
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