region = "vegas-1"

network_shift = 1

vpc_cidr = ["10.101.70.0/24", "fd10:101:70::/64"]

nodes = {
  "pve2" = {
    storage = "local-zfs",
    gw4     = "10.101.70.1",
    gw6     = "2600:8801:2aa0:b307::1",
    vlan_id = 70,
    trunks  = "70;1610",
  }
}

controlplane = {
  "pve2" = {
    id    = 1500,
    count = 3,
    cpu   = 4,
    mem   = 8192,
  }
}

cluster_name = "homelab-k8s"

cluster_endpoint = "https://homelab-k8s.local.xuhuisun.com:6443"