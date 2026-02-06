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

data "talos_image_factory_extensions_versions" "worker_extensions" {
  talos_version = local.talos_release_version
  filters = {
    names = [
      "qemu-guest-agent"
    ]
  }
}

data "talos_image_factory_extensions_versions" "gpu_worker_extensions" {
  talos_version = local.talos_release_version
  filters = {
    names = [
      "qemu-guest-agent",
      "nvidia-open-gpu-kernel-modules-lts",
      "nvidia-container-toolkit-lts",
    ]
  }
}

resource "talos_image_factory_schematic" "worker_image_factory_schematic" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.worker_extensions.extensions_info.*.name
        }
      }
    }
  )
}

resource "talos_image_factory_schematic" "gpu_worker_image_factory_schematic" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.gpu_worker_extensions.extensions_info.*.name
        }
      }
    }
  )
}

data "talos_image_factory_urls" "talos_image" {
  talos_version = local.talos_release_version
  schematic_id  = talos_image_factory_schematic.worker_image_factory_schematic.id
  architecture  = local.talos_architecture
  platform      = local.talos_platform
}

data "talos_image_factory_urls" "gpu_talos_image" {
  talos_version = local.talos_release_version
  schematic_id  = talos_image_factory_schematic.gpu_worker_image_factory_schematic.id
  architecture  = local.talos_architecture
  platform      = local.talos_platform
}