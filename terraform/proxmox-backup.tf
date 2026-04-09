locals {
  vm_id = sort(distinct(concat(
    values(proxmox_virtual_environment_vm.controlplane)[*].vm_id,
    values(proxmox_virtual_environment_vm.bastion)[*].vm_id,
    values(proxmox_virtual_environment_vm.gpu-worker-template)[*].vm_id,
    values(proxmox_virtual_environment_vm.worker-template)[*].vm_id,
  )))
}

resource "proxmox_backup_job" "talos_daily_backup" {
  id               = "talos-daily-backup"
  schedule         = "2,22:30"
  storage          = "pbs-nfs"
  vmid             = local.vm_id
  mode             = "snapshot"
  compress         = "zstd"
  prune_backups    = { keep-all = "1" }
  notes_template   = "{{guestname}}"
  mailnotification = "failure"
  mailto           = ["ericsun1995@gmail.com"]

  depends_on = [proxmox_virtual_environment_vm.bastion, proxmox_virtual_environment_vm.controlplane]
}