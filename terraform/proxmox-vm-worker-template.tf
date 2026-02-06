resource "proxmox_virtual_environment_vm" "worker-template" {
  for_each = { for inx, zone in local.zones : zone => inx }

  name        = "talos-worker-template"
  description = "Talos worker template"
  tags        = ["managed-by_terraform", "os_linux", "os-sku_talos", "os-image-version_${local.talos_image_version}", "type_k8s-worker-template"]

  node_name = each.key
  vm_id     = lookup(try(var.controlplane[each.key], {}), "id", 9000) + each.value + 100

  template = true

  agent {
    enabled = true
  }

  startup {
    order = "2"
  }

  cpu {
    cores   = 1
    sockets = 1
    numa    = true
    type    = "host"
  }

  machine = "q35"

  disk {
    datastore_id = var.nodes[each.key].storage
    file_id      = proxmox_virtual_environment_download_file.talos_cloud_image[each.key].id
    interface    = "scsi0"
    iothread     = true
    cache        = "none"
    size         = 3
    ssd          = true
    discard      = "on"
    file_format  = "raw"
  }

  initialization {
    dns {
      servers = [var.nodes[each.key].gw4, var.nodes[each.key].gw6]
    }

    ip_config {
      ipv4 {
        address = "dhcp"
      }
      ipv6 {
        address = "auto"
      }
    }

    datastore_id = var.nodes[each.key].storage
  }

  network_device {
    bridge  = var.nodes[each.key].bridge
    mtu     = 1
    vlan_id = var.nodes[each.key].vlan_id
    trunks  = var.nodes[each.key].trunks
  }

  operating_system {
    type = "l26"
  }

  scsi_hardware = "virtio-scsi-single"

  tpm_state {
    version      = "v2.0"
    datastore_id = var.nodes[each.key].storage
  }

  lifecycle {
    ignore_changes = [
      started,
      initialization,
      cpu,
      memory,
      network_device,
    ]
  }

  depends_on = [
    proxmox_virtual_environment_download_file.talos_cloud_image,
  ]
}