# homelab-k8s

### Prerequisite
- Helm
- Oh my zsh kubectl plugin

### Traefik
#### Setup apps
```bash
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
k create namespace traefik
helm upgrade --install traefik traefik/traefik --values=traefik/values.yaml --namespace=traefik --create-namespace
```
#### Dashboards
```bash
k apply -f traefik/traefik-dashborad-ingress.yaml
k create namespace proxmox
k apply -f traefik/pve-dashboard-ingress.yaml
```
