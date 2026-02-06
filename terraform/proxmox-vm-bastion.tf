locals {
  bastion_prefix = "bastion"

  bastions = { for k in flatten([
    for zone in local.zones : [
      {
        id : lookup(try(var.bastion[zone], {}), "id", 8000)
        name : "${local.bastion_prefix}-${zone}"
        zone : zone
        cpu : lookup(try(var.bastion[zone], {}), "cpu", 1)
        mem : lookup(try(var.bastion[zone], {}), "mem", 2048),

        ipv4 : cidrhost(cidrsubnet(var.vpc_cidr[0], 4, var.network_shift + index(local.zones, zone)), -1 )
        gwv4 : lookup(try(var.nodes[zone], {}), "gw4", local.gwv4)
        gwv6 : lookup(try(var.nodes[zone], {}), "gw6", "fe80::1")
      }
    ]
  ]) : k.name => k }
}

resource "proxmox_virtual_environment_file" "bastion_cloud_config" {
  for_each = { for inx, zone in local.zones : zone => inx }

  node_name    = each.key
  content_type = "snippets"
  datastore_id = "local"

  source_raw {
    data = <<-EOF
    #cloud-config
    hostname: ${each.key}-bastion
    manage_etc_hosts: true

    users:
      - default
      - name: esun-local
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        lock_passwd: true
        ssh_authorized_keys:
          - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDA6z9feYMrDUpipR47F2o8elkMQ+/hcAwKqQ6rTwNYrTYm71QFMFL1nqVJGv6bNi80EV14MW3oxRktBU/Rz3XBrMzFLsJzzHgvwgB7ZGWeIV/sUs5XLDM1SGWyJDWdNYZjDxDfmYICCLLQJbj1nVQqsa59RR80suzR6omOBKywRpiuDx75r+/8fm8uCSDVyJt6UlT0b/lPsZHTlOGkGRkDlSz2LXPprMBYYVLPAGth1tza4tTY0NjEENBOdStmV/W9xawxIcdJiuHjoec/1FRT0JjSzcB6apH56vL6qf4hftP/XNWOmym0zQvTpIqOdhSGwrdkqShzwBx/z1Sx8QsswVSyv39TYtihLzjxQNWwY1er+QUaFSEcD9pSoP37bumEo4tmYt49ZRc33lhrLr+EB7kE9dRYYfNtLTwscrV7gh4pSgwY9VqaB4jqCIodS42aRPqIqW8bujFPpqTg9nHA9Aa7YcmdIjmreYUUHVQba0KXqPp7UHyQKSm26yCpHbE= xuhui@xuhui-LinuxWorkstation

    ssh_pwauth: false
    disable_root: true

    package_update: true
    packages:
      - qemu-guest-agent

    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
    EOF 

    file_name = "install-agent.yaml"
  }
}

resource "proxmox_virtual_environment_vm" "bastion" {
  for_each = local.bastions

  name        = each.value.name
  description = "Bastion host for ${each.value.zone}"
  tags        = ["managed-by_terraform", "os_linux", "os-sku_ubuntu", "os-image-version_noble-server-cloudimg-amd64", "type_vm"]

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
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image[each.value.zone].id
    interface    = "scsi0"
    iothread     = true
    cache        = "none"
    size         = 32
    ssd          = true
    discard      = "on"
    file_format  = "raw"
  }

  initialization {
    dns {
      servers = [each.value.gwv4, each.value.gwv6]
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
    user_data_file_id = proxmox_virtual_environment_file.bastion_cloud_config[each.value.zone].id
  }

  network_device {
    bridge  = var.nodes[each.value.zone].bridge
    queues      = each.value.cpu
    mtu     = 1
    vlan_id = var.nodes[each.value.zone].vlan_id
  }

  operating_system {
    type = "l26"
  }

  scsi_hardware = "virtio-scsi-single"

  bios = "ovmf"
  efi_disk {
    datastore_id = var.nodes[each.value.zone].storage
  }
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
    ]
  }

  depends_on = [
    proxmox_virtual_environment_download_file.ubuntu_cloud_image,
    proxmox_virtual_environment_file.bastion_cloud_config,
  ]
}