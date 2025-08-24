data "helm_template" "cilium" {
  name       = "cilium"
  namespace  = "kube-system"
  repository = "https://helm.cilium.io/"

  chart        = "cilium"
  version      = "1.18.0"
  kube_version = "v1.33.0"

  values = [
    file("${path.module}/files/cilium.yaml")
  ]
}