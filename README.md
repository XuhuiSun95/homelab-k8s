# homelab-k8s

Installing Kubernetes with Kubespray with kube_vip, metric server, cert manager,
metallb, argocd enabled.

Renovate scan and bump up helm chart dependencies' version and ArgoCD for
in-cluster deployment.

### Setup k8s
```bash
docker pull quay.io/kubespray/kubespray:v2.24.0
docker run --rm -it --mount type=bind,source="$(pwd)"/ansible/inventory/myculster,dst=/inventory \
  --mount type=bind,source="${HOME}"/.ssh/id_rsa,dst=/root/.ssh/id_rsa \
  quay.io/kubespray/kubespray:v2.24.0 bash

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
#### Setup secret for grafana generic oauth client secret
```bash
  export client_secret=<supersecretsupersecretsupersecret>
kubectl create secret generic auth-generic-oauth-secret --from-literal="client_secret=$client_secret" --namespace monitoring
```
#### Setup secret for elasticsearch snapshot minio secret
```bash
  export YOUR_ACCESS_KEY=<supersecretsupersecretsupersecret>
  export YOUR_SECRET_ACCESS_KEY=<supersecretsupersecretsupersecret>
kubectl create secret generic snapshot-settings \
   --from-literal=s3.client.default.access_key=$YOUR_ACCESS_KEY \
   --from-literal=s3.client.default.secret_key=$YOUR_SECRET_ACCESS_KEY \
   --namespace elastic
```
#### Setup openebs block device tags
```bash
# setup openebs block device tag
kubectl label bd -n openebs <bd> openebs.io/block-device-tag=prometheus

kubectl label bd -n openebs <bd> openebs.io/block-device-tag=minio

kubectl label bd -n openebs <bd> openebs.io/block-device-tag=zookeeper

kubectl label bd -n openebs <bd> openebs.io/block-device-tag=kafka

kubectl label bd -n openebs <bd> openebs.io/block-device-tag=cstor

kubectl label bd -n openebs <bd> openebs.io/block-device-tag=elasticsearch
```

### All in one deployment
```bash
kubectl apply -f deployment.yaml
```
#### Keycloak token
```bash
kubectl -n keycloak get secret keycloak -o jsonpath="{.data.admin-password}" | base64 -d | xclip
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
### Kibana token
```bash
kubectl -n elastic get secret elasticsearch-es-elastic-user -o jsonpath="{.data.elastic}" | base64 --decode | xclip
```

### Upgrade
#### Graceful upgrade kubespary version and config
```bash
ansible-playbook -i /inventory/inventory.ini --private-key /root/.ssh/id_rsa upgrade-cluster.yml -u esun-local -b
```
#### OpenEBS cstor cspc and volume
```bash
kubectl apply -f jobs/cstor-cspc-upgrade-<version>.yaml
kubectl apply -f jobs/cstor-volume-upgrade-<version>.yaml
```

<!-- ### Rook (HCI ceph only) -->
<!-- #### Setup apps -->
<!-- ```bash -->
<!-- helm repo add rook-release https://charts.rook.io/release -->
<!-- helm repo update -->
<!-- helm upgrade --install rook-ceph rook-release/rook-ceph --values=rook/values.yaml --namespace=rook-ceph --create-namespace -->
<!-- helm upgrade --install rook-ceph-cluster --set operatorNamespace=rook-ceph rook-release/rook-ceph-cluster --values=rook/values.yaml --namespace=rook-ceph --create-namespace -->
<!-- kubectl create -f rook/storageclass.yaml -->
<!-- ``` -->


grafana dashboard config error(dashboardproviders)
