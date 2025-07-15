# homelab-k8s

Installing Kubernetes with Kubespray with kube_vip, metric server, cert manager,
metallb, argocd enabled.

Renovate scan and bump up helm chart dependencies' version and ArgoCD for
in-cluster deployment.

### Setup k8s
```bash
docker pull quay.io/kubespray/kubespray:v2.27.0
docker run --rm -it --mount type=bind,source="$(pwd)"/ansible/inventory/myculster,dst=/inventory \
  --mount type=bind,source="${HOME}"/.ssh/id_rsa,dst=/root/.ssh/id_rsa \
  quay.io/kubespray/kubespray:v2.27.0 bash

ansible-playbook -i /inventory/inventory.ini --private-key /root/.ssh/id_rsa cluster.yml -u esun-local -b
```
#### Seed ArgoCD
We need manually deploy ArgoCD for the very first time, then later it can be
managed by the ArgoCD application to achieve self-managed state.
```bash
helm upgrade --install argocd argo/argo-cd --values=argocd/values.yaml --namespace=argocd --create-namespace
```
#### Setup NFS CSI Driver DeleteVolume mount options
```bash
kubectl create secret generic nfs-mount-options --from-literal mountOptions="nolock" --namespace kube-system
```
#### Setup secret for cert-manager cluster issuer
```bash
  export aws_secret=<supersecretsupersecretsupersecret>
kubectl create secret generic route53-credentials-secret --from-literal="secret-access-key=$aws_secret" --namespace cert-manager
```
#### Setup secret for external-dns unifi webhook
```bash
  export api_key=<supersecretsupersecretsupersecret>
kubectl create secret generic external-dns-unifi-secret --from-literal="api-key=$api_key" --namespace external-dns
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
### Kibana token
```bash
kubectl -n elastic get secret elasticsearch-es-elastic-user -o jsonpath="{.data.elastic}" | base64 --decode | xclip
```

### Upgrade
#### Graceful upgrade kubespary version and config
```bash
ansible-playbook -i /inventory/inventory.ini --private-key /root/.ssh/id_rsa upgrade-cluster.yml -u esun-local -b
```

loki
