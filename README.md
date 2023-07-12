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
#### Setup node label(application deployment and node selection)
```bash
kubectl label nodes worker-01 disktype=ssd
kubectl label nodes worker-02 disktype=ssd
kubectl label nodes worker-03 disktype=ssd
kubectl label nodes worker-04 disktype=ssd
kubectl label nodes worker-05 disktype=ssd
```
#### Setup secret for cert-manager cluster issuer
```bash
  export aws_secret=<supersecretsupersecretsupersecret>
kubectl create secret generic route53-credentials-secret --from-literal="secret-access-key=$aws_secret" --namespace cert-manager
```
#### Setup openebs block device tags
```bash
# setup openebs block device tag
kubectl label bd -n openebs <bd> openebs.io/block-device-tag=prometheus

kubectl label bd -n openebs <bd> openebs.io/block-device-tag=minio
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

### All in one deployment
```bash
kubectl apply -f deployment.yaml
```

### Istio
#### ArgoCD
```bash
# To get login token
kubectl apply -f argocd/ingress/argocd.yaml
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d | xclip
```
#### Prometheus dashboard
```bash
kubectl apply -f kube-prometheus-stack/ingress/prometheus.yaml
kubectl apply -f kube-prometheus-stack/ingress/grafana.yaml
```
#### External services
```bash
kubectl apply -f istio/virtual-services/pve1.yaml
kubectl apply -f istio/virtual-services/pve2.yaml
```
#### Kiali
```bash
# To get login token
kubectl apply -f kiali/ingress/kiali-console.yaml
kubectl -n istio-system create token kiali-service-account | xclip
```

<!-- ### Heimdall -->
<!-- #### Setup apps -->
<!-- ```bash -->
<!-- helm repo add djjudas21 https://djjudas21.github.io/charts -->
<!-- helm repo update -->
<!-- helm upgrade --install heimdall djjudas21/heimdall --namespace heimdall --create-namespace -->

<!-- kubectl apply -f heimdall/ingress/heimdall.yaml -->
<!-- ``` -->


### MinIO
#### Setup operator
```bash
# To get login token
kubectl apply -f minio/ingress/minio-operator-console.yaml
kubectl -n minio-operator  get secret console-sa-secret -o jsonpath="{.data.token}" | base64 --decode | xclip
```
#### Setup tenant
```bash
# kubectl label namespace minio istio-injection=enabled --overwrite

kubectl apply -f minio/ingress/minio-tenant-console.yaml
kubectl apply -f minio/ingress/minio-tenant-s3.yaml
```
