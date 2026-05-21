output "ccm" {
  sensitive = true
  value     = proxmox_user_token.ccm.value
}

output "csi" {
  sensitive = true
  value     = proxmox_user_token.csi.value
}

output "karpenter" {
  sensitive = true
  value     = proxmox_user_token.karpenter.value
}

output "bastions" {
  value = local.bastions
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

output "talos_installer_image" {
  description = "Talos Image Factory installer URL (control plane and workers). Use with talosctl upgrade --image."
  value       = data.talos_image_factory_urls.talos_image.urls.installer
}