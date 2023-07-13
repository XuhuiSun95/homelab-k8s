# homelab-k8s

Installing Kubernetes with Kubespray with kube_vip, metric server, cert manager,
metallb, argocd enabled.

Renovate scan and bump up helm chart dependencies' version and ArgoCD for
in-cluster deployment.

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

kubectl label bd -n openebs <bd> openebs.io/block-device-tag=cstor
```

### All in one deployment
```bash
kubectl apply -f deployment.yaml
```
#### ArgoCD token
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d | xclip
```
#### Kiali token
```bash
kubectl -n istio-system create token kiali-service-account | xclip
```
#### Minio operator token
```bash
kubectl -n minio-operator  get secret console-sa-secret -o jsonpath="{.data.token}" | base64 --decode | xclip
```

<!-- ### Heimdall -->
<!-- #### Setup apps -->
<!-- ```bash -->
<!-- helm repo add djjudas21 https://djjudas21.github.io/charts -->
<!-- helm repo update -->
<!-- helm upgrade --install heimdall djjudas21/heimdall --namespace heimdall --create-namespace -->

<!-- kubectl apply -f heimdall/ingress/heimdall.yaml -->
<!-- ``` -->

<!-- ### MinIO -->
<!-- #### Setup tenant -->
<!-- ```bash -->
<!-- # kubectl label namespace minio istio-injection=enabled --overwrite -->
<!-- ``` -->

<!-- ### Rook (HCI ceph only) -->
<!-- #### Setup apps -->
<!-- ```bash -->
<!-- helm repo add rook-release https://charts.rook.io/release -->
<!-- helm repo update -->
<!-- helm upgrade --install rook-ceph rook-release/rook-ceph --values=rook/values.yaml --namespace=rook-ceph --create-namespace -->
<!-- helm upgrade --install rook-ceph-cluster --set operatorNamespace=rook-ceph rook-release/rook-ceph-cluster --values=rook/values.yaml --namespace=rook-ceph --create-namespace -->
<!-- kubectl create -f rook/storageclass.yaml -->
<!-- ``` -->
