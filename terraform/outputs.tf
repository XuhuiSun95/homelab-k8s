output "ccm" {
  sensitive = true
  value     = proxmox_virtual_environment_user_token.ccm.value
}

output "csi" {
  sensitive = true
  value     = proxmox_virtual_environment_user_token.csi.value
}

output "karpenter" {
  sensitive = true
  value     = proxmox_virtual_environment_user_token.karpenter.value
}

output "controlplanes" {
  value = local.controlplanes
}

output "talosconfig" {
  sensitive = true
  value     = data.talos_client_configuration.talosconfig.talos_config
}

output "kubeconfig" {
  sensitive = true
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
}