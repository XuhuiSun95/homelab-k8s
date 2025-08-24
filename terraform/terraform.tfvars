region = "vegas-1"

vpc_cidr = ["10.101.70.0/24", "fd10:101:70::/64"]

nodes = {
  "pve2" = {
    storage = "local-zfs",
    gw4     = "10.101.70.1",
    gw6     = "2600:8801:2aa0:b302::1",
    vlan_id = 70,
    trunks  = "70;3",
  }
}

controlplane = {
  "pve2" = {
    id    = 1500,
    count = 1,
    cpu   = 4,
    mem   = 4096,
  }
}

cluster_name = "homelab-k8s"

cluster_vip = "10.101.3.21"

cluster_vip_domain = "homelab-k8s.local.xuhuisun.com"

cluster_endpoint = "https://homelab-k8s.local.xuhuisun.com:6443"