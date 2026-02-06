resource "proxmox_virtual_environment_download_file" "talos_cloud_image" {
  for_each = { for inx, zone in local.zones : zone => inx }

  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key
  overwrite    = false
  url          = data.talos_image_factory_urls.talos_image.urls.iso
  file_name    = "talos-${local.talos_image_version}.iso"
}

resource "proxmox_virtual_environment_download_file" "gpu_talos_cloud_image" {
  for_each = { for inx, zone in local.zones : zone => inx }

  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key
  overwrite    = false
  url          = data.talos_image_factory_urls.gpu_talos_image.urls.iso
  file_name    = "gpu-talos-${local.talos_image_version}.iso"
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  for_each = { for inx, zone in local.zones : zone => inx }

  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key
  overwrite    = false
  url          = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  file_name    = "noble-server-cloudimg-amd64.img"
}