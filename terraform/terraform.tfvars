region = "vegas-1"

vpc_cidr = ["10.101.60.0/24", "fd10:101:60::/64"]

nodes = {
  "pve2" = {
    storage = "local-zfs",
    gw4     = "10.101.60.1",
    gw6     = "2600:8801:2aa0:b303::1",
    vlan_id = 160,
    trunks  = "160;1610",
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