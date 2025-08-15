resource "proxmox_virtual_environment_download_file" "talos_cloud_image" {
  for_each = { for inx, zone in local.zones : zone => inx }

  content_type = "iso"
  datastore_id = "local"
  node_name    = each.key
  overwrite    = false

  # Hash: 376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba customization: {}
  # Hash: 14e9b0100f05654bedf19b92313cdc224cbff52879193d24f3741f1da4a3cbb1 customization: siderolabs/binfmt-misc
  # Hash: ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515 customization: siderolabs/qemu-guest-agent
  url = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v${var.release}/nocloud-amd64.iso"
}