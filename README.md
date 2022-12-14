# homelab-k8s

### Prerequisite
- Helm
- Oh my zsh kubectl plugin

### OpenEBS
#### Setup apps
```bash
helm repo add openebs https://openebs.github.io/charts
helm repo update
k create namespace openebs
helm upgrade --install openebs openebs/openebs --values=openebs/values.yaml --namespace=openebs --create-namespace
k patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
k patch storageclass openebs-device -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

### Reflector
#### Setup apps
```bash
helm repo add emberstack https://emberstack.github.io/helm-charts
helm repo update
k create namespace reflector
helm upgrade --install reflector emberstack/reflector --values=reflector/values.yaml --namespace=reflector --create-namespace
```

### Cert-Manager
#### Setup apps
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.crds.yaml
k create namespace cert-manager
helm upgrade --install cert-manager jetstack/cert-manager --values=cert-manager/values.yaml --namespace=cert-manager --create-namespace --version v1.9.1
```
#### Setup certs
```bash
  export aws_secret=<supersecretsupersecretsupersecret>
k create secret generic route53-credentials-secret --from-literal="secret-access-key=$aws_secret" --namespace cert-manager
k apply -f cert-manager/issuers/letsencrypt-production.yaml
k apply -f cert-manager/certificates/production/local-xuhuisun-com.yaml
```

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

### Kube-Prometheus-Stack
#### Setup apps
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
k create namespace monitoring
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack --values=kube-prometheus-stack/values.yaml --namespace=monitoring --create-namespace
```
#### Dashboards
```bash
k apply -f kube-prometheus-stack/grafana-dashboard-ingress.yaml
```
