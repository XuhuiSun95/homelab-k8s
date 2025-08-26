locals {
  controlplane_prefix = "control-plane"
  controlplane_labels = "node-pool=control-plane"

  controlplanes = { for k in flatten([
    for zone in local.zones : [
      for inx in range(lookup(try(var.controlplane[zone], {}), "count", 0)) : {
        id : lookup(try(var.controlplane[zone], {}), "id", 9000) + inx
        name : "${local.controlplane_prefix}-${format("%02d", index(local.zones, zone))}${format("%x", 10 + inx)}"
        zone : zone
        cpu : lookup(try(var.controlplane[zone], {}), "cpu", 1)
        mem : lookup(try(var.controlplane[zone], {}), "mem", 2048)

        ipv4 : cidrhost(cidrsubnet(var.vpc_cidr[0], 4, var.network_shift + index(local.zones, zone)), -(2 + inx))
        gwv4 : lookup(try(var.nodes[zone], {}), "gw4", local.gwv4)

        vlan_id : lookup(try(var.nodes[zone], {}), "vlan_id", null)
        trunks : lookup(try(var.nodes[zone], {}), "trunks", null)
      }
    ]
  ]) : k.name => k }

  controlplane_v4 = [for ip in local.controlplanes : ip.ipv4]
}

resource "proxmox_virtual_environment_file" "controlplane_metadata" {
  for_each = local.controlplanes

  node_name    = each.value.zone
  content_type = "snippets"
  datastore_id = "local"

  source_raw {
    data = templatefile("${path.module}/templates/metadata.yaml.tmpl", {
      hostname : each.value.name,
      id : each.value.id,
      type : "${each.value.cpu}VCPU-${floor(each.value.mem / 1024)}GB",
      providerID : "proxmox://${var.region}/${each.value.id}",
      region : var.region,
      zone : each.value.zone,
    })
    file_name = "${each.value.name}.metadata.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "controlplane" {
  for_each = local.controlplanes

  name        = each.value.name
  description = "Talos controlplane at ${var.region}"
  tags        = ["managed-by_terraform", "os_linux", "os-sku_talos", "os-image-version_${local.talos_image_version}", "type_k8s", "type-k8s-role_control-plane"]

  node_name = each.value.zone
  vm_id     = each.value.id

  agent {
    enabled = true
  }

  startup {
    order = "1"
  }

  cpu {
    cores   = each.value.cpu
    sockets = 1
    numa    = true
    type    = "host"
  }

  machine = "q35"

  memory {
    dedicated = each.value.mem
  }

  disk {
    datastore_id = var.nodes[each.value.zone].storage
    file_id      = proxmox_virtual_environment_download_file.talos_cloud_image[each.value.zone].id
    interface    = "scsi0"
    iothread     = true
    cache        = "none"
    size         = 50
    ssd          = true
    file_format  = "raw"
  }

  initialization {
    dns {
      servers = [each.value.gwv4]
    }
    ip_config {
      ipv4 {
        address = "${each.value.ipv4}/24"
        gateway = each.value.gwv4
      }
      ipv6 {
        address = "auto"
      }
    }

    datastore_id      = var.nodes[each.value.zone].storage
    meta_data_file_id = proxmox_virtual_environment_file.controlplane_metadata[each.key].id
  }

  network_device {
    bridge      = "vmbr0"
    queues      = each.value.cpu
    mtu         = 1
    mac_address = "32:90:${join(":", formatlist("%02X", split(".", each.value.ipv4)))}"
    vlan_id     = each.value.vlan_id
    trunks      = each.value.trunks
  }

  operating_system {
    type = "l26"
  }

  scsi_hardware = "virtio-scsi-single"

  tpm_state {
    version      = "v2.0"
    datastore_id = var.nodes[each.value.zone].storage
  }

  lifecycle {
    ignore_changes = [
      started,
      initialization,
      cpu,
      memory,
      disk,
      network_device,
    ]
  }

  depends_on = [
    proxmox_virtual_environment_file.controlplane_metadata,
    proxmox_virtual_environment_download_file.talos_cloud_image,
  ]
}