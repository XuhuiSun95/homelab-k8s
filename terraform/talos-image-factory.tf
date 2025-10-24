data "talos_image_factory_versions" "talos_latest_stable_version" {
  filters = {
    stable_versions_only = true
  }
}

locals {
  talos_release_version = var.release == "latest" ? element(data.talos_image_factory_versions.talos_latest_stable_version.talos_versions, length(data.talos_image_factory_versions.talos_latest_stable_version.talos_versions) - 1) : var.release
  talos_architecture    = "amd64"
  talos_platform        = "nocloud"
  talos_image_version   = "${local.talos_platform}-${local.talos_architecture}-${local.talos_release_version}"
}

data "talos_image_factory_urls" "talos_image" {
  talos_version = local.talos_release_version
  # Hash: 376567988ad370138ad8b2698212367b8edcb69b5fd68c80be1f2ec7d603b4ba customization: {}
  # Hash: 14e9b0100f05654bedf19b92313cdc224cbff52879193d24f3741f1da4a3cbb1 customization: siderolabs/binfmt-misc
  # Hash: ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515 customization: siderolabs/qemu-guest-agent
  schematic_id = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
  architecture = local.talos_architecture
  platform     = local.talos_platform
}