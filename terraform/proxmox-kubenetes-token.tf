resource "proxmox_virtual_environment_user" "kubernetes" {
  acl {
    path      = "/"
    propagate = true
    role_id   = proxmox_virtual_environment_role.ccm.role_id
  }
  acl {
    path      = "/"
    propagate = true
    role_id   = proxmox_virtual_environment_role.csi.role_id
  }
  acl {
    path      = "/"
    propagate = true
    role_id   = proxmox_virtual_environment_role.karpenter.role_id
  }

  comment = "Kubernetes"
  user_id = "kubernetes@pve"
}

resource "proxmox_virtual_environment_user_token" "ccm" {
  comment    = "Kubernetes CCM"
  token_name = "ccm"
  user_id    = proxmox_virtual_environment_user.kubernetes.user_id
}

resource "proxmox_virtual_environment_user_token" "csi" {
  comment    = "Kubernetes CSI"
  token_name = "csi"
  user_id    = proxmox_virtual_environment_user.kubernetes.user_id
}

resource "proxmox_virtual_environment_user_token" "karpenter" {
  comment    = "Kubernetes Karpenter"
  token_name = "karpenter"
  user_id    = proxmox_virtual_environment_user.kubernetes.user_id
}

resource "proxmox_virtual_environment_role" "ccm" {
  role_id = "CCM"

  privileges = [
    "VM.Audit",
    "Sys.Audit",
  ]
}

resource "proxmox_virtual_environment_role" "csi" {
  role_id = "CSI"

  privileges = [
    "VM.Audit",
    "VM.Config.Disk",
    "Datastore.Allocate",
    "Datastore.AllocateSpace",
    "Datastore.Audit",
  ]
}

resource "proxmox_virtual_environment_role" "karpenter" {
  role_id = "Karpenter"

  privileges = [
    "Datastore.Allocate",
    "Datastore.AllocateSpace",
    "Datastore.AllocateTemplate",
    "Datastore.Audit",
    "Mapping.Audit",
    "Mapping.Use",
    "Sys.Audit",
    "Sys.AccessNetwork",
    "SDN.Audit",
    "SDN.Use",
    "VM.Audit",
    "VM.Allocate",
    "VM.Clone",
    "VM.Config.CDROM",
    "VM.Config.CPU",
    "VM.Config.Memory",
    "VM.Config.Disk",
    "VM.Config.Network",
    "VM.Config.HWType",
    "VM.Config.Cloudinit",
    "VM.Config.Options",
    "VM.PowerMgmt"
  ]
}

resource "proxmox_virtual_environment_acl" "ccm" {
  token_id = proxmox_virtual_environment_user_token.ccm.id
  role_id  = proxmox_virtual_environment_role.ccm.role_id

  path      = "/"
  propagate = true
}

resource "proxmox_virtual_environment_acl" "csi" {
  token_id = proxmox_virtual_environment_user_token.csi.id
  role_id  = proxmox_virtual_environment_role.csi.role_id

  path      = "/"
  propagate = true
}

resource "proxmox_virtual_environment_acl" "karpenter" {
  token_id = proxmox_virtual_environment_user_token.karpenter.id
  role_id  = proxmox_virtual_environment_role.karpenter.role_id

  path      = "/"
  propagate = true
}