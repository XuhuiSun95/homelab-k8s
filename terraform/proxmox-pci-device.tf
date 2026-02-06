resource "proxmox_virtual_environment_hardware_mapping_pci" "nvidia-gpu" {
  for_each = { for inx, zone in local.zones : zone => inx if lookup(var.nodes[zone], "pci_devices", []) != [] }

  comment = "NVIDIA GPU"
  name    = "nvidia-gpu-${each.key}"

  map = [
    for pci_device in var.nodes[each.key].pci_devices : {
      id           = pci_device.id
      node         = each.key
      path         = pci_device.path
      subsystem_id = pci_device.subsystem_id
      iommu_group  = pci_device.iommu_group
    }
  ]
}