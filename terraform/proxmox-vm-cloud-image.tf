resource "proxmox_virtual_environment_download_file" "talos_cloud_image" {
  for_each = { for inx, zone in local.zones : zone => inx }

  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key
  overwrite    = false
  url          = data.talos_image_factory_urls.talos_image.urls.iso
  file_name    = "talos-${local.talos_image_version}.iso"
}