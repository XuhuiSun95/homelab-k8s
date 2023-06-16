# homelab-k8s

### Prerequisite
- Helm
- Oh my zsh kubectl plugin

### Rook
#### Setup apps
```bash
helm repo add rook-release https://charts.rook.io/release
helm repo update
helm upgrade --install rook-ceph rook-release/rook-ceph --values=rook/values.yaml --namespace=rook-ceph --create-namespace
helm upgrade --install rook-ceph-cluster --set operatorNamespace=rook-ceph rook-release/rook-ceph-cluster --values=rook/values.yaml --namespace=rook-ceph --create-namespace
kubectl create -f rook/storageclass.yaml
```

### OpenEBS
#### Setup apps
```bash
helm repo add openebs https://openebs.github.io/charts
helm repo update
helm upgrade --install openebs openebs/openebs --values=openebs/values.yaml --namespace=openebs --create-namespace
```

### MetalLB
### Setup apps
```bash
helm repo add metallb https://metallb.github.io/metallb
helm repo update
helm upgrade --install metallb metallb/metallb --values=metallb/values.yaml --namespace=metallb-system --create-namespace
```
#### Setup pools
```bash
kubectl apply -f metallb/pools/vlan60.yaml
```

### Cert-Manager
#### Setup apps
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.1/cert-manager.crds.yaml
helm upgrade --install cert-manager jetstack/cert-manager --values=cert-manager/values.yaml --namespace=cert-manager --create-namespace --version v1.12.1
```
#### Setup cluster issuer
```bash
  export aws_secret=<supersecretsupersecretsupersecret>
kubectl create secret generic route53-credentials-secret --from-literal="secret-access-key=$aws_secret" --namespace cert-manager
kubectl apply -f cert-manager/issuers/letsencrypt-production.yaml
```

### Istio
#### Setup apps
```bash
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm upgrade --install istio-base istio/base --namespace=istio-system --create-namespace
# In the output locate the entry for istio-base and make sure the status is set to deployed.
helm upgrade --install istiod istio/istiod --namespace=istio-system --create-namespace --wait
helm upgrade --install istio-ingress istio/gateway --values=istio/values.yaml --namespace=istio-ingress --create-namespace --wait
```
#### Kiali dashboard
```bash
helm repo add kiali https://kiali.org/helm-charts
helm repo update
helm upgrade --install kiali-operator kiali/kiali-operator --set cr.create=true --set cr.namespace=istio-system --namespace kiali-operator --create-namespace

# To get login token
kubectl -n istio-system create token kiali-service-account
```
#### Ingress gateway
```bash
kubectl apply -f istio/certificates/production/local-xuhuisun-com.yaml
kubectl apply -f istio/gateway/default.yaml
kubectl apply -f istio/virtual-service/kiali-console.yaml
kubectl apply -f istio/virtual-service/heimdall.yaml
kubectl apply -f istio/virtual-service/pve.yaml
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
