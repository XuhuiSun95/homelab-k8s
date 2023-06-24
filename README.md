# homelab-k8s

### Prerequisite
- Helm
- Oh my zsh kubectl plugin

### Setup k8s
```bash
docker pull quay.io/kubespray/kubespray:v2.22.1
docker run --rm -it --mount type=bind,source="$(pwd)"/ansible/inventory/myculster,dst=/inventory \
  --mount type=bind,source="${HOME}"/.ssh/id_rsa,dst=/root/.ssh/id_rsa \
  quay.io/kubespray/kubespray:v2.22.1 bash

ansible-playbook -i /inventory/inventory.ini --private-key /root/.ssh/id_rsa cluster.yml -u esun-local -b
```

### Rook (HCI ceph only)
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
#### Setup node label
```bash
kubectl label nodes worker-01 disktype=ssd
kubectl label nodes worker-02 disktype=ssd
kubectl label nodes worker-03 disktype=ssd
kubectl label nodes worker-04 disktype=ssd
kubectl label nodes worker-05 disktype=ssd
```

### Cert-Manager
#### Setup cluster issuer
```bash
  export aws_secret=<supersecretsupersecretsupersecret>
kubectl create secret generic route53-credentials-secret --from-literal="secret-access-key=$aws_secret" --namespace cert-manager
kubectl apply -f cert-manager/issuers/letsencrypt-production.yaml
```

### Kube-Prometheus-Stack
#### Setup apps
```bash
kubectl label bd -n openebs <bd> openebs.io/block-device-tag=prometheus
kubectl apply -f kube-prometheus-stack/storageclass/prometheus.yaml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack --values=kube-prometheus-stack/values.yaml --namespace=monitoring --create-namespace
```

### Istio
#### Setup apps
```bash
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
helm upgrade --install istio-base istio/base --namespace=istio-system --create-namespace
# In the output locate the entry for istio-base and make sure the status is set to deployed.
helm upgrade --install istiod istio/istiod --values=istio/istiod-values.yaml --namespace=istio-system --create-namespace --wait
helm upgrade --install istio-ingress istio/gateway --values=istio/gateway-values.yaml --namespace=istio-ingress --create-namespace --wait
```
#### Ingress gateway
```bash
kubectl apply -f istio/certificates/production/local-xuhuisun-com.yaml
kubectl apply -f istio/gateways/default.yaml
```
#### External services
```bash
kubectl apply -f istio/virtual-services/heimdall.yaml
kubectl apply -f istio/virtual-services/pve1.yaml
kubectl apply -f istio/virtual-services/pve2.yaml
```
#### Kiali
<!-- TODO fix prometheus integration -->
```bash
helm repo add kiali https://kiali.org/helm-charts
helm repo update
helm upgrade --install kiali-operator kiali/kiali-operator --values=kiali/values.yaml --namespace kiali-operator --create-namespace

# To get login token
kubectl apply -f kiali/ingress/kiali-console.yaml
kubectl -n istio-system create token kiali-service-account | xclip
```
#### Prometheus dashboard
```bash
kubectl apply -f kube-prometheus-stack/ingress/prometheus.yaml
kubectl apply -f kube-prometheus-stack/ingress/grafana.yaml
```

### MinIO
#### Setup operator
```bash
kubectl label bd -n openebs <bd> openebs.io/block-device-tag=minio
kubectl apply -f minio/storageclass/minio.yaml

helm upgrade --install minio-operator minio/operator --values=minio/operator-values.yaml --namespace minio-operator --create-namespace

# To get login token
kubectl apply -f minio/ingress/minio-operator-console.yaml
kubectl -n minio-operator  get secret console-sa-secret -o jsonpath="{.data.token}" | base64 --decode | xclip
```
#### Setup tenant
```bash
helm upgrade --install tenant minio/tenant --values=minio/values.yaml --namespace minio --create-namespace

# kubectl label namespace minio istio-injection=enabled --overwrite

kubectl apply -f minio/ingress/minio-tenant-console.yaml
kubectl apply -f minio/ingress/minio-tenant-s3.yaml
```
