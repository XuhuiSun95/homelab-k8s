locals {
  ubuntu_release_version = "resolute"
  ubuntu_architecture    = "amd64"
  ubuntu_platform        = "server-cloudimg"
  ubuntu_image_version   = "${local.ubuntu_release_version}-${local.ubuntu_platform}-${local.ubuntu_architecture}"
}