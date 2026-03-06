# Homelab Kubernetes Cluster

> **Production-ready Kubernetes homelab infrastructure** built with Talos Linux, Proxmox, GitOps (ArgoCD), Istio service mesh, and comprehensive observability stack. Features auto-scaling with Karpenter, zero-trust security, and full cloud-native tooling.

[![Kubernetes](https://img.shields.io/badge/kubernetes-1.29+-blue.svg)](https://kubernetes.io/)
[![Talos Linux](https://img.shields.io/badge/Talos-blue)](https://www.talos.dev/)
[![Terraform](https://img.shields.io/badge/terraform-1.0+-purple.svg)](https://www.terraform.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-blue)](https://argo-cd.readthedocs.io/)
[![Istio](https://img.shields.io/badge/Istio-blue)](https://istio.io/)

Component versions are defined in Terraform variables (`terraform.tfvars`, `variables.tf`) and ArgoCD application `targetRevision` / Helm values.

A comprehensive, production-grade Kubernetes homelab infrastructure built on **Talos Linux** and **Proxmox**. This repository provides a complete cloud-native platform featuring GitOps workflows, service mesh capabilities, full observability (LGTM stack), auto-scaling, and enterprise-grade security. Perfect for learning Kubernetes, running personal services, or building a production-like environment at home.

## 📑 Table of Contents

- [🏗️ Architecture Overview](#️-architecture-overview)
- [🛠️ Technology Stack](#️-technology-stack)
- [📊 Services Dashboard](#-services-dashboard)
- [🚀 Deployment Categories](#-deployment-categories)
- [🛠️ Setup Instructions](#️-setup-instructions)
- [🔑 Access Credentials](#-access-credentials)
- [🔄 Maintenance & Upgrades](#-maintenance--upgrades)
- [🌐 Network Configuration](#-network-configuration)
- [🎯 Key Features](#-key-features)
- [💡 Use Cases](#-use-cases)
- [📁 Repository Structure](#-repository-structure)
- [🔧 Configuration Highlights](#-configuration-highlights)
- [🤝 Contributing](#-contributing)
- [📚 Documentation & Resources](#-documentation--resources)
- [🚨 Important Notes](#-important-notes)
- [🏷️ Topics & Tags](#️-topics--tags)

## ⚠️ Temporary Warning

**Known Issue**: When using Cilium with eBPF host routing (kubeproxyreplacement) and Istio ambient mode enabled, there is a known health probe issue that causes readiness and liveness probes to fail.

**Fix**: Apply the fix following the instructions at [Istio Issue #57911](https://github.com/istio/istio/issues/57911). The fix involves patching the `istio-cni-node` DaemonSet to set `HOST_PROBE_SNAT_IP` environment variable to use `status.hostIP`:

```yaml
spec:
  template:
    spec:
      containers:
      - name: install-cni
        env:
        - name: HOST_PROBE_SNAT_IP
          valueFrom:
            fieldRef:
              apiVersion: v1
              fieldPath: status.hostIP
```

## 🏗️ Architecture Overview

This homelab deploys a **production-ready Kubernetes cluster** using modern cloud-native technologies:

- **Infrastructure**: **Talos Linux** on **Proxmox VMs** with **Terraform** for immutable Kubernetes deployment
- **Cloud Provider**: **Proxmox** integration with **Cloud Controller Manager (CCM)**, **Container Storage Interface (CSI)**, and **Karpenter** for automation
- **Networking**: **Cilium CNI** with **eBPF** host routing (kubeProxyReplacement), **BGP** integration, and dual-stack **IPv4/IPv6** support
- **Auto-scaling**: **Karpenter** with Proxmox provider for dynamic node provisioning and workload scaling
- **GitOps**: **ArgoCD** for declarative application management and continuous delivery
- **Service Mesh**: **Istio Ambient Mode** for zero-trust traffic management, security, and observability
- **Ingress**: Custom domain (`local.xuhuisun.com`) with **Let's Encrypt** certificates via **cert-manager**
- **Storage**: Multiple storage solutions (**AIStor** S3-compatible with MinKMS, **NFS CSI**, **CloudNativePG** PostgreSQL, **Proxmox CSI**)
- **Observability**: Complete **LGTM stack** (Loki, Grafana, Tempo, Mimir) plus **ELK stack** (Elasticsearch, Kibana)
- **Authentication**: **Keycloak** for identity and access management with **OIDC** integration
- **Automation**: **Renovate** for dependency updates, **KEDA** for event-driven auto-scaling

## 🛠️ Technology Stack

### Core Infrastructure
- **Kubernetes**: Container orchestration platform
- **Talos Linux**: Immutable, API-driven Linux distribution for Kubernetes
- **Proxmox VE**: Virtualization platform and hypervisor
- **Terraform**: Infrastructure as Code (IaC) tool

### Networking & Service Mesh
- **Cilium**: eBPF-based CNI plugin with advanced networking features
- **Istio**: Service mesh with ambient mode (zero-trust networking)
- **BGP**: Border Gateway Protocol for advanced routing

### GitOps & CI/CD
- **ArgoCD**: GitOps continuous delivery tool
- **Renovate**: Automated dependency updates

### Observability & Monitoring
- **LGTM Stack**: Loki (logs), Grafana (visualization), Tempo (traces), Mimir (metrics)
- **ELK Stack**: Elasticsearch, Logstash, Kibana
- **OpenTelemetry Kube Stack**: Unified observability framework with automated instrumentation and metrics collection
- **Kiali**: Service mesh observability

### Storage Solutions
- **AIStor**: S3-compatible object storage with MinKMS key management (MinIO-compatible)
- **CloudNativePG**: PostgreSQL operator for Kubernetes
- **NFS CSI**: Network File System support
- **Proxmox CSI**: Native Proxmox block storage

### Security & Authentication
- **Keycloak**: Identity and Access Management (IAM)
- **cert-manager**: Automated certificate lifecycle management
- **mTLS**: Mutual TLS for service-to-service encryption

### Auto-scaling & Orchestration
- **Karpenter**: Dynamic node provisioning and scaling
- **KEDA**: Event-driven autoscaling for workloads

## 📊 Services Dashboard

Access your services at [Homepage Dashboard](https://homepage.local.xuhuisun.com)

### 🔐 Management & Security
| Service | URL | Purpose |
|---------|-----|---------|
| **ArgoCD** | https://argocd.local.xuhuisun.com | GitOps continuous delivery |
| **Keycloak** | https://keycloak.local.xuhuisun.com | Identity & access management |
| **IAM (OIDC)** | https://iam.local.xuhuisun.com | OIDC issuer / SSO (Keycloak) |
| **Homepage** | https://homepage.local.xuhuisun.com | Service dashboard |
| **Registry Mirror (Harbor)** | https://registry-mirror.local.xuhuisun.com | Pull-through cache for docker.io, ghcr.io, registry.k8s.io, public.ecr.aws, quay.io |

### 📈 Observability & Monitoring
| Service | URL | Purpose |
|---------|-----|---------|
| **Grafana** | https://grafana.local.xuhuisun.com | Metrics visualization |
| **Mimir** | https://mimir.local.xuhuisun.com | Long-term metrics storage |
| **Kiali** | https://kiali.local.xuhuisun.com | Istio service mesh console |
| **Kibana** | https://kibana.local.xuhuisun.com | Elasticsearch visualization |

### 💾 Storage & Data
| Service | URL | Purpose |
|---------|-----|---------|
| **AIStor Console** | https://aistor-console.local.xuhuisun.com | Object storage management (MinKMS) |
| **AIStor S3 API** | https://aistor.local.xuhuisun.com | S3-compatible API endpoint |

### 🤖 AI & Productivity
| Service | URL | Purpose |
|---------|-----|---------|
| **Open-WebUI** | https://open-webui.local.xuhuisun.com | AI interface (LLM frontend) |
| **OpenClaw** | https://openclaw-cluster-admin-agent.local.xuhuisun.com | AI agent Control UI (Telegram, Discord, in-cluster admin; [openclaw-rocks/k8s-operator](https://github.com/openclaw-rocks/k8s-operator)) |
| **Immich** | https://immich.local.xuhuisun.com | Photo management & backup |
| **n8n** | https://n8n.local.xuhuisun.com | Workflow automation |

### 🏠 Infrastructure
| Service | URL | Purpose |
|---------|-----|---------|
| **Proxmox Datacenter Manager** | https://pdm.local.xuhuisun.com | Proxmox cluster management |
| **Proxmox VE** | https://pve2.local.xuhuisun.com | Hypervisor management |
| **Proxmox Backup** | https://pbs.local.xuhuisun.com | Backup management |
| **Scrypted** | https://scrypted.local.xuhuisun.com | Home automation |

## 🚀 Deployment Categories

This homelab includes a comprehensive set of **cloud-native applications** organized by category:

### API Gateway & Ingress
- **Istio Ingress Gateway**: HTTP/HTTPS traffic routing with **TLS termination** and load balancing
- **Certificate Management**: Automated **Let's Encrypt** certificates via **cert-manager** with **Route53** DNS validation

### Cloud Native Storage
- **AIStor**: **S3-compatible object storage** with **MinKMS** key management for backups, artifacts, and data lake
- **CloudNativePG**: **PostgreSQL operator** for Kubernetes-native database management
- **NFS CSI Driver**: **Network File System** support for shared storage
- **Proxmox CSI**: Native **Proxmox block storage** provisioner for persistent volumes

### Continuous Integration/Delivery (CI/CD)
- **ArgoCD**: **GitOps platform** for declarative Kubernetes deployments
- **Self-healing**: Automated drift detection and correction with continuous sync
- **Renovate**: Automated dependency and Helm chart updates

### DNS & Network Management
- **External DNS**: Automated **DNS record management** with **Unifi** integration
- **Istio Service Mesh**: Advanced **traffic management**, **security policies**, and **observability**

### Observability & Monitoring Stack
- **LGTM Stack**: Complete observability with **Loki** (distributed logs), **Grafana** (visualization), **Tempo** (distributed traces), **Mimir** (distributed metrics)
- **OpenTelemetry Kube Stack**: Unified observability framework with **automated instrumentation** and **metrics collection** - replaces Prometheus stack
- **Elastic Stack**: **Elasticsearch** and **Kibana** for advanced log analytics and search
- **Kiali**: **Service mesh visualization** and traffic flow analysis
- **Metrics Server**: **Kubernetes metrics API** implementation for **HPA** and **VPA**

### Security & Compliance
- **Cert-Manager**: Automated **certificate lifecycle management** with **Let's Encrypt** integration
- **Keycloak**: Enterprise **identity and access management (IAM)** with **OIDC** and **OAuth2**
- **OIDC Integration**: **Single sign-on (SSO)** across all services
- **mTLS**: **Mutual TLS** encryption for service-to-service communication via **Istio**

### Service Mesh
- **Istio Ambient Mode**: **Zero-trust service mesh** without sidecars using **ztunnel** for secure overlay
- **Istio Base**: Core **service mesh functionality** and control plane
- **Istio CNI**: **Network plugin** for pod-to-pod encryption and traffic policies
- **Istio Ztunnel**: **Secure overlay network** for ambient mode with **L4 encryption**
- **Traffic Policies**: Advanced **routing**, **load balancing**, **circuit breaking**, and **retry logic**

### Streaming & Messaging
- **Strimzi Kafka**: **Apache Kafka** operator for Kubernetes with **high availability**
- **OAuth Authentication**: Secured **Kafka access** via **Keycloak** integration

### Auto-scaling & Orchestration
- **KEDA**: **Event-driven autoscaling** for workloads based on metrics, queues, and external events
- **Karpenter**: **Dynamic node provisioning** and scaling with **Proxmox** integration

## 🛠️ Setup Instructions

This guide will help you deploy a **production-ready Kubernetes cluster** on **Proxmox** using **Talos Linux** and **Terraform**. The setup follows **Infrastructure as Code** best practices and uses **GitOps** for application management.

### Prerequisites

Before starting, ensure you have:

- A **Proxmox VE** cluster with appropriate storage and network configuration
- Network access to your Proxmox cluster
- Basic knowledge of **Kubernetes**, **Terraform**, and **Linux**

Install required tools:

```bash
# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Install Talos CLI
curl -sL https://talos.dev/install | sh
sudo mv talosctl /usr/local/bin/

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

**Note**: This setup requires a Proxmox VE cluster with appropriate storage and network configuration.

### 1. Initial Kubernetes Cluster Setup

Deploy Kubernetes using Talos Linux with Terraform on Proxmox:

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Configure Proxmox credentials. This project uses Terraform Cloud for the backend (see terraform/terraform.tf).
# Set credentials either in the Terraform Cloud workspace or via a local file:
cat > credentials.auto.tfvars << EOF
virtual_environment_endpoint = "https://<pve-ip>:8006"
virtual_environment_api_token = "your-proxmox-api-token"
virtual_environment_ssh_username = "root"
EOF

# Review and customize terraform.tfvars for your environment
# Key parameters:
# - region: Proxmox cluster name
# - nodes: Proxmox nodes with storage and network config
# - controlplane: Control plane VM specifications
# - cluster_name: Kubernetes cluster name
# - cluster_endpoint: API server endpoint

# Plan the deployment
terraform plan

# Deploy the infrastructure (creates control plane VMs and bootstraps cluster)
terraform apply

# Get the talosconfig
terraform output -raw talosconfig > talosconfig

# Configure talosctl
export TALOSCONFIG="$(pwd)/talosconfig"

# Get the kubeconfig
terraform output -raw kubeconfig > kubeconfig

# Configure kubectl
export KUBECONFIG="$(pwd)/kubeconfig"

# Verify cluster is running
kubectl get nodes
kubectl get pods --all-namespaces
```

### 2. Configure Cluster Networking and Cloud Providers

Deploy Cilium CNI with BGP integration and Proxmox cloud integrations. **Run all commands in this step from the `terraform` directory** (paths like `files/` are relative to it).

```bash
# Add Helm repositories
helm repo add cilium https://helm.cilium.io/

# Install Talos Cloud Controller Manager
# Note: CCM credentials are automatically configured via inline manifests
helm upgrade -i talos-cloud-controller-manager oci://ghcr.io/siderolabs/charts/talos-cloud-controller-manager --namespace kube-system --values files/talos-ccm.yaml

# Install Cilium CNI with advanced networking features
helm upgrade -i cilium cilium/cilium --namespace kube-system --values files/cilium.yaml

# Apply Cilium BGP Configuration (for routing and load balancer IP pools)
kubectl apply -f files/cilium-bgp.yaml

# Install Proxmox Cloud Controller Manager
# Note: CCM credentials are automatically configured via inline manifests
helm upgrade -i proxmox-cloud-controller-manager oci://ghcr.io/sergelogvinov/charts/proxmox-cloud-controller-manager --namespace kube-system --values files/proxmox-ccm.yaml

# Install Proxmox CSI Plugin (block storage provisioner)
# Note: CSI credentials are automatically configured via inline manifests
helm upgrade -i proxmox-csi-plugin oci://ghcr.io/sergelogvinov/charts/proxmox-csi-plugin --namespace kube-system --values files/proxmox-csi.yaml 

# Install Karpenter Provider Proxmox (dynamic node provisioning)
# Note: Karpenter credentials and worker template are configured via inline manifests
helm upgrade -i karpenter-provider-proxmox oci://ghcr.io/sergelogvinov/charts/karpenter-provider-proxmox --namespace kube-system --values files/proxmox-karpenter.yaml 

# Configure Karpenter NodePool for system and user workloads
kubectl apply -f files/karpenter-node.yaml

# Add custom priority class
kubectl apply -f files/priority-class.yaml
```

### 3. Bootstrap ArgoCD

From the **repository root**, deploy ArgoCD manually for the first time (it will self-manage afterwards):

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd \
  --values=argocd/values.yaml \
  --namespace=argocd \
  --create-namespace
```

### 4. Required Secrets Setup

#### NFS CSI Driver Configuration
```bash
kubectl create secret generic nfs-mount-options \
  --from-literal mountOptions="nolock" \
  --namespace kube-system
```

#### Cert-Manager Route53 Credentials
```bash
 export aws_secret=<your_aws_secret_access_key>
kubectl create secret generic route53-credentials-secret \
  --from-literal="secret-access-key=$aws_secret" \
  --namespace cert-manager
```

#### External DNS Unifi Integration
```bash
 export api_key=<your_unifi_api_key>
kubectl create secret generic external-dns-unifi-secret \
  --from-literal="api-key=$api_key" \
  --namespace external-dns
```

#### Elasticsearch MinIO Snapshots
```bash
 export YOUR_ACCESS_KEY=<minio_access_key>
 export YOUR_SECRET_ACCESS_KEY=<minio_secret_key>
kubectl create secret generic snapshot-settings \
  --from-literal=s3.client.default.access_key=$YOUR_ACCESS_KEY \
  --from-literal=s3.client.default.secret_key=$YOUR_SECRET_ACCESS_KEY \
  --namespace elastic
```

#### OpenClaw agents
Create the required secrets in the `openclaw` namespace **before** deploying OpenClaw agents (e.g. via Argo CD). Agents reference these via `spec.envFrom`; without them, pods may fail to start or integrations (Discord, etc.) will not work.

**Environment and integration tokens** (e.g. Discord bot token, AI provider keys if not in env-vars). Create `openclaw-env-vars`:

```bash
export DISCORD_BOT_TOKEN=<discord_bot_token>
kubectl create secret generic openclaw-env-vars \
  --from-literal="DISCORD_BOT_TOKEN=$DISCORD_BOT_TOKEN" \
  --namespace openclaw
```

Add more `--from-literal` entries for other integrations or API keys as needed (e.g. `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`). Ensure the `openclaw` namespace exists, or create it first: `kubectl create namespace openclaw`. Agent definitions are in `openclaw/agents/` (one `OpenClawInstance` YAML per agent); Istio ingress is in `openclaw/ingress/`.

#### MinKMS Operator MinIO License
If you use the MinKMS operator (e.g. for AIStor) with a commercial MinIO license, create a secret from your license file so the operator can use it:

```bash
kubectl create secret generic minio-license -n minkms-operator --from-file minio.license
```

Ensure the `minio.license` file is in your current directory, or pass the full path: `--from-file /path/to/minio.license`. The namespace `minkms-operator` must exist (it is created when the minkms-operator Argo CD application is deployed).

#### AIStor Operator MinIO License
If you use the AIStor operator with a commercial MinIO license, create a secret from your license file in the `aistor` namespace:

```bash
kubectl create secret generic minio-license -n aistor --from-file minio.license
```

Ensure the `minio.license` file is in your current directory, or pass the full path: `--from-file /path/to/minio.license`. The namespace `aistor` must exist (it is created when the aistor-operator Argo CD application is deployed).

#### MinKMS Enclave for AIStor
Before deploying AIStor (e.g. the `aistor-objectstore` object store), create the MinKMS enclave so AIStor can use it for key management. Run this **before** deploying the AIStor operator or object store:

```bash
minkms add-enclave aistor-objectstore -k
```

The enclave name `aistor-objectstore` must match the object store name used in your AIStor configuration. The `-k` flag creates the necessary keys for the enclave. Ensure the `minkms` CLI is installed and you are authenticated to your MinKMS instance.

#### CNPG database backup to internal AIStor (MinIO)
CloudNativePG clusters that back up to the **internal** AIStor/MinIO endpoint (e.g. `https://minio.primary-object-store.svc.cluster.local`) need the cluster root CA so the Postgres pods can verify TLS. Create the `minio-ca-bundle` secret in **each namespace** where a CNPG cluster uses `backups.endpointURL` pointing at that internal host and has `endpointCA.name: minio-ca-bundle` in its values (e.g. Keycloak, or n8n if using the internal endpoint).

Example for the **keycloak** namespace (repeat for other namespaces that use internal AIStor for backups, e.g. `n8n`):

```bash
 export ca_crt=$(kubectl get cm kube-root-ca.crt -o jsonpath="{['data']['ca\\.crt']}")
kubectl create secret generic minio-ca-bundle --from-literal="ca-bundle.crt=$ca_crt" --namespace keycloak
```

Ensure the cluster’s backup config references this secret, for example in `keycloak/cnpg-cluster-values.yaml`:

```yaml
backups:
  enabled: true
  endpointURL: https://minio.primary-object-store.svc.cluster.local
  endpointCA:
    create: false
    name: minio-ca-bundle
    key: ca-bundle.crt
  provider: s3
  s3:
    bucket: cloudnative-pg-backups
    # accessKey / secretKey from your object store credentials
```

Create the secret **before** or right after deploying the CNPG cluster so scheduled and manual backups can run without TLS verification errors.

#### Proxmox Cloud Provider Credentials
The Proxmox credentials for CCM, CSI, and Karpenter are automatically configured during cluster bootstrap via inline manifests in Talos. No manual secret creation is needed for Proxmox integrations.

### 5. Deploy All Applications

From the **repository root**, deploy the entire stack using GitOps:

```bash
kubectl apply -f deployment.yaml
```

This deploys the root ArgoCD Application that recursively syncs `argocd/applications`, installing all applications in the correct order via sync waves.

### 6. Apply Istio CNI Health Probe Fix (Required for Cilium with eBPF Host Routing)

If you're using Cilium with `kubeProxyReplacement` enabled and Istio ambient mode, you must apply the health probe fix to prevent probe failures:

```bash
# Patch the istio-cni-node DaemonSet to set HOST_PROBE_SNAT_IP
kubectl patch daemonset istio-cni-node -n istio-system --type='json' \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/env/-", "value": {"name": "HOST_PROBE_SNAT_IP", "valueFrom": {"fieldRef": {"apiVersion": "v1", "fieldPath": "status.hostIP"}}}}]'
```

Alternatively, you can manually edit the DaemonSet:

```bash
kubectl edit daemonset istio-cni-node -n istio-system
```

Add the following environment variable to the `install-cni` container:

```yaml
env:
- name: HOST_PROBE_SNAT_IP
  valueFrom:
    fieldRef:
      apiVersion: v1
      fieldPath: status.hostIP
```

See the [warning section](#-temporary-warning) at the top of this README for more details.

### 7. Apply Mimir Record/Alert Rules and Alertmanager Config
```bash
mimirtool rules list --address=https://mimir.local.xuhuisun.com --id=homelab-k8s

mimirtool rules load ./lgtm/mimir-control-plane-rules.yaml --address=https://mimir.local.xuhuisun.com --id=homelab-k8s
mimirtool rules load ./lgtm/mimir-kube-prometheus-rules.yaml --address=https://mimir.local.xuhuisun.com --id=homelab-k8s
mimirtool rules load ./lgtm/mimir-kube-state-metrics-rules.yaml --address=https://mimir.local.xuhuisun.com --id=homelab-k8s
mimirtool rules load ./lgtm/mimir-node-exporter-rules.yaml --address=https://mimir.local.xuhuisun.com --id=homelab-k8s

mimirtool rules load ./strimzi/kafka/strimzi-rule.yaml --address=https://mimir.local.xuhuisun.com --id=homelab-k8s

# Alertmanager config (routing, receivers, etc.)
mimirtool alertmanager load ./lgtm/mimir-alertmanager.yaml --address=https://mimir.local.xuhuisun.com --id=homelab-k8s
```

### 8. Registry Mirror (Harbor)

Harbor provides a **pull-through cache** at **https://registry-mirror.local.xuhuisun.com**. Talos nodes (controlplane and workers) are configured to use this mirror for **docker.io**, **ghcr.io**, **registry.k8s.io**, **public.ecr.aws**, and **quay.io**, so image pulls are served from the cache when possible and only hit upstream on cache miss.

- **Change the mirror URL**: Set the Terraform variable `registry_mirror_endpoint` (default `https://registry-mirror.local.xuhuisun.com`), e.g. in `terraform.tfvars` or via `-var`, then re-apply and roll or re-apply Talos machine config so nodes pick up the new endpoint.
- **Harbor proxy cache projects**: Create proxy cache project(s) in the Harbor UI (or API) for each upstream registry so the cache keys match what Talos uses (e.g. project names `docker.io`, `ghcr.io`, `registry.k8s.io`, `public.ecr.aws`, `quay.io`). The Terraform Talos provider uses string-only mirror endpoints; for path-based Harbor proxies with `overridePath`, see [Talos: Harbor as a caching registry](https://docs.siderolabs.com/talos/v1.12/configure-your-talos-cluster/images-container-runtime/pull-through-cache#using-harbor-as-a-caching-registry) and apply mirror config via `talosctl` if needed. See [Harbor: Configure Proxy Cache](https://goharbor.io/docs/main/administration/configure-proxy-cache/).
- **Existing nodes**: After changing Terraform/Talos config, apply the updated machine config to existing nodes (e.g. `talosctl apply-config` or roll nodes). New nodes (e.g. from Karpenter) receive the config from the applied templates automatically.

## 🔑 Access Credentials

### Talos Cluster Management
```bash
# Set talosconfig
export TALOSCONFIG="$(pwd)/terraform/talosconfig"

# Get cluster status
talosctl get nodes
talosctl get services
talosctl get pods

# View cluster configuration
talosctl get config
talosctl get machineconfig

# Restart services
talosctl restart kubelet
talosctl restart containerd
```

### ArgoCD Admin Password
```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d | xclip
```

### Keycloak Admin Password
```bash
kubectl -n keycloak get secret keycloak \
  -o jsonpath="{.data.admin-password}" | base64 -d | xclip
```

### Kiali Service Token
```bash
kubectl -n istio-system create token kiali-service-account | xclip
```

### Elasticsearch/Kibana Password
```bash
kubectl -n elastic get secret elasticsearch-es-elastic-user \
  -o jsonpath="{.data.elastic}" | base64 --decode | xclip
```

### AIStor / Object Storage Credentials
```bash
# AIStor (object store) credentials are configured in aistor/aistor-objectstore-values.yaml
# For legacy MinIO tenant, check minio/tenant-values.yaml for access key and secret
```

## 🔄 Maintenance & Upgrades

### Kubernetes Cluster Upgrade

Upgrade Talos Linux and Kubernetes to the latest version:

#### Automatic Upgrade to Latest Version

Terraform automatically detects and upgrades to the latest stable Talos version when `release = "latest"` is set in `terraform.tfvars` (this is the default).

**Steps:**

1. **Upgrade talosctl CLI** to latest version:
   ```bash
   # Upgrade talosctl to latest version
   curl -sL https://talos.dev/install | sh
   ```

2. **Modify Terraform values and plan** - Update Kubernetes version and auto-detect latest Talos image:
   ```bash
   # Navigate to terraform directory
   cd terraform
   
   # Edit terraform/terraform.tfvars and update kubernetes_version to match new Talos image
   # Example:
   # kubernetes_version = "v1.35.0"
   
   # Review planned changes (Terraform will auto-detect latest Talos version)
   terraform plan
   ```

3. **Apply the upgrade** - Run terraform apply to upgrade:
   ```bash
   # Apply the upgrade (this will recreate VMs with new Talos version)
   terraform apply
   ```

   **Note:** Steps 2 and 3 only upgrade the template for future Karpenter provisioned nodes. Existing nodes are not upgraded automatically. New nodes created by Karpenter will use the updated Talos image template.

4. **Manually upgrade Talos control plane nodes** by running CLI:
   ```bash
   # Upgrade control plane nodes (replace node IP and image version with corresponding values)
   talosctl upgrade --nodes <NODE_IP> --image factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:<VERSION>
   
   # Example:
   # talosctl upgrade --nodes 10.101.70.30 --image factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.12.0
   ```

5. **Resync inline manifests** (e.g. Karpenter template secret) by running `talosctl upgrade-k8s` to the current Kubernetes version on a control plane node:
   ```bash
   # Replace <NODE_IP> with a control plane node IP and use the cluster's current k8s version
   talosctl upgrade-k8s --nodes <NODE_IP> --to <CURRENT_K8S_VERSION>

   # Example (current version 1.35.0):
   # talosctl upgrade-k8s --nodes 10.101.70.30 --to 1.35.0
   ```
   This resyncs the inline manifests (including the Karpenter template secret) without changing the Kubernetes version.

6. **Drift or delete old Karpenter provisioned nodes** so Karpenter can provision new nodes with the new Talos image and machine config:
   ```bash
   # Option 1: Drift nodes (mark for replacement - Karpenter will gracefully replace them)
   kubectl annotate node <NODE_NAME> karpenter.sh/do-not-consolidate=true
   kubectl delete node <NODE_NAME> --grace-period=0
   
   # Option 2: Directly delete old nodes (replace <NODE_NAME> with actual node name)
   kubectl delete node <NODE_NAME>
   
   # Karpenter will automatically provision new nodes with the updated Talos image and machine config
   # Monitor node provisioning
   kubectl get nodes -w
   ```

7. **Verify cluster health** after upgrade:
   ```bash
   # Verify Talos nodes
   talosctl get nodes
   
   # Verify Kubernetes nodes
   kubectl get nodes
   kubectl get pods --all-namespaces
   
   # Verify Proxmox integrations are working
   kubectl get pods -n kube-system | grep -E "(proxmox|karpenter|cilium)"
   ```


### Proxmox Node Management
Worker nodes are automatically managed by Karpenter. Control plane nodes are managed by Terraform. To scale worker nodes:
- System workloads: Karpenter automatically provisions based on Pod requirements
- User workloads: Karpenter automatically provisions based on Pod requirements
- Manual scaling: Edit NodePool limits in `terraform/files/karpenter-node.yaml`
- Pool isolation: system and memory-optimized nodes are tainted (Talos CCM); workloads use nodeSelector/tolerations so only one pool can satisfy each pod. Underutilized consolidation runs 24/7, rate-limited by NodePool disruption budgets (20%, max 1 node) and workload PDBs (cert-manager, Argo CD, Istio, Strimzi, LGTM).

### Application Updates
- **Automated**: Renovate automatically creates PRs for Helm chart updates
- **Manual**: Update `targetRevision` in ArgoCD application manifests
- **Self-healing**: ArgoCD automatically syncs any configuration drift

## 🌐 Network Configuration

### Domain Structure
- **Primary Domain**: `local.xuhuisun.com`
- **Wildcard Certificate**: `*.local.xuhuisun.com` (Let's Encrypt)
- **DNS Provider**: Unifi with External DNS automation
- **TLS Termination**: Istio Ingress Gateway
- **BGP Integration**: Cilium BGP for LoadBalancer IP advertisement
- **Load Balancer IPs**: Managed via CiliumLoadBalancerIPPool resources

### Sync Wave Deployment Order
1. **Wave 0**: Cloud providers and CNI (Cilium, Proxmox CCM, Talos CCM, Proxmox CSI, Karpenter provider, priority classes)
2. **Wave 10**: Cilium BGP, NFS CSI driver, Karpenter NodePools, Metrics Server, ArgoCD ingress
3. **Wave 20**: Cert-Manager (certificate management)
4. **Wave 21**: Vertical Pod Autoscaler
5. **Wave 30**: Istio (service mesh) and OpenTelemetry Kube Stack
6. **Wave 40**: Harbor (container registry)
7. **Wave 41**: KEDA (event-driven autoscaling)
8. **Wave 42**: ArgoCD (GitOps)
9. **Wave 50**: External DNS (DNS automation)
10. **Wave 60**: Storage and observability operators (AIStor, CloudNativePG, ECK, Kiali)
11. **Wave 70**: Keycloak and LGTM stack
12. **Wave 80**: Strimzi (Kafka)
13. **Wave 200**: User applications (Homepage, Open-WebUI, OpenClaw, Immich, n8n)

## 🎯 Key Features

- **🔄 GitOps Workflow**: Everything managed as code with **ArgoCD** - declarative, version-controlled infrastructure
- **🔒 Security First**: **mTLS**, **OAuth2/OIDC**, automated certificate management with **cert-manager** and **Let's Encrypt**
- **📊 Full Observability**: Complete **metrics, logs, traces** collection with **LGTM stack**, **OpenTelemetry Kube Stack**, and service mesh visibility via **Kiali**
- **🚀 Auto-scaling**: **KEDA** for event-driven scaling and **Karpenter** for dynamic node provisioning
- **💾 Multiple Storage**: **Block storage** (Proxmox CSI), **object storage** (AIStor S3 / MinKMS), **file storage** (NFS), and **database storage** (CloudNativePG)
- **🤖 AI Ready**: **Open-WebUI** for LLM interactions and AI workloads
- **🏠 Home Integration**: **Proxmox** virtualization, **Scrypted** home automation, and network infrastructure
- **⚡ Immutable Infrastructure**: **Talos Linux** provides immutable, API-driven operating system with read-only root filesystem
- **🔧 Infrastructure as Code**: Complete cluster lifecycle managed with **Terraform** - from VM creation to Kubernetes bootstrap
- **🛡️ Enhanced Security**: Minimal attack surface with **Talos Linux**, zero-trust networking via **Istio Ambient Mode**
- **📦 Container-Optimized**: Built specifically for **Kubernetes workloads** with optimized resource usage
- **🔄 Dynamic Scaling**: **Karpenter** auto-scales nodes based on workload demand with Proxmox integration
- **🏷️ Node Pool Management**: Separate pools for system and user workloads with resource isolation
- **🌐 Advanced Networking**: **Cilium eBPF** datapath, **BGP** routing, dual-stack **IPv4/IPv6**, and **DSR** mode support
- **🔍 Service Mesh**: **Istio Ambient Mode** for zero-trust security without sidecar overhead

## 💡 Use Cases

This Kubernetes homelab is perfect for:

- **Learning Kubernetes**: Hands-on experience with production-grade Kubernetes tooling
- **Personal Cloud Services**: Self-hosted alternatives to cloud services (photo management, AI tools, storage)
- **Development Environment**: Production-like environment for testing and development
- **Home Automation**: Centralized platform for smart home services and automation
- **DevOps Practice**: Real-world experience with GitOps, service mesh, observability, and infrastructure automation
- **Cost Optimization**: Run cloud-native workloads on-premises with enterprise features
- **Security Research**: Zero-trust networking, mTLS, and advanced security configurations
- **CNCF Technology Exploration**: Hands-on experience with CNCF projects (Istio, ArgoCD, Cilium, etc.)

## 📁 Repository Structure

```
├── terraform/                   # Talos Linux infrastructure as code
│   ├── files/                   # Kubernetes manifests and Helm values
│   │   ├── cilium.yaml         # Cilium CNI configuration (BGP, DSR, dual-stack)
│   │   ├── cilium-bgp.yaml     # Cilium BGP routing configuration
│   │   ├── proxmox-ccm.yaml    # Proxmox Cloud Controller Manager
│   │   ├── proxmox-csi.yaml    # Proxmox CSI Plugin
│   │   ├── proxmox-karpenter.yaml # Karpenter Proxmox provider
│   │   ├── karpenter-node.yaml # Karpenter NodePool definitions
│   │   ├── priority-class.yaml # Kubernetes priority classes
│   │   └── talos-ccm.yaml      # Talos Cloud Controller Manager
│   ├── templates/              # Talos configuration templates
│   │   ├── controlplane.yaml.tmpl # Control plane configuration (Proxmox integration)
│   │   ├── metadata.yaml.tmpl  # VM metadata template
│   │   ├── worker.yaml.tmpl    # Worker node template for Karpenter
│   │   └── gpu-worker.yaml.tmpl # GPU worker node template
│   ├── terraform.tfvars        # Terraform variables (customize for your Proxmox)
│   ├── terraform.tf            # Terraform backend (Terraform Cloud) and required providers
│   ├── variables.tf            # Variable definitions
│   ├── outputs.tf              # Terraform outputs (kubeconfig, talosconfig, credentials)
│   ├── providers.tf            # Terraform provider configuration
│   ├── network.tf              # Network configuration and helpers
│   ├── talos-bootstrap.tf      # Talos cluster bootstrap and kubeconfig generation
│   ├── proxmox-kubenetes-token.tf # Proxmox API tokens for cloud providers
│   ├── proxmox-vm-cloud-image.tf  # Talos image management in Proxmox
│   ├── proxmox-vm-control-plane.tf # Control plane VM definitions
│   ├── proxmox-vm-worker-template.tf # Worker template for Karpenter
│   ├── proxmox-vm-gpu-worker-template.tf # GPU worker template
│   ├── proxmox-vm-bastion.tf   # Bastion host VM
│   ├── proxmox-pci-device.tf   # PCI device passthrough configuration
│   └── talos-image-factory.tf  # Talos image factory integration
├── argocd/                     # ArgoCD configuration and applications
│   ├── applications/           # Application definitions by category
│   │   ├── cloud-controller-manager/ # Proxmox & Talos CCM
│   │   ├── cloud-native-network/ # Cilium CNI and BGP
│   │   ├── cloud-native-storage/ # Storage solutions (AIStor, NFS CSI, Proxmox CSI)
│   │   ├── continuous-integration-delivery/ # ArgoCD
│   │   ├── container-registry/ # Harbor (pull-through cache)
│   │   ├── continuous-optimization/ # Karpenter, VPA, priority classes
│   │   ├── database/           # CloudNativePG operator
│   │   ├── dns/                # External DNS
│   │   ├── observability/      # LGTM, ECK, Kiali, Metrics Server (mertics-server.yaml), OpenTelemetry
│   │   ├── scheduling-orchestration/ # KEDA
│   │   ├── security-compliance/ # Cert-Manager, Keycloak
│   │   ├── service-mesh/       # Istio
│   │   ├── streaming-messaging/ # Strimzi Kafka
│   │   └── user-defined-apps/  # Homepage, Immich, n8n, Open-WebUI, OpenClaw
│   └── values.yaml            # ArgoCD Helm values
├── aistor/                    # AIStor object storage (MinKMS operator, AIStor operator, object store, ingress)
├── cert-manager/              # Certificate management
├── cloudnative-pg/            # CloudNativePG operator configuration
├── csi-driver-nfs/            # NFS CSI driver configuration
├── eck/                       # Elastic Cloud on Kubernetes
├── external-dns/              # External DNS configuration
├── harbor/                    # Harbor registry mirror (values, ArgoCD app, ingress)
├── homepage/                  # Service dashboard
├── immich/                    # Photo management application
├── istio/                     # Service mesh configuration
├── keda/                      # Event-driven autoscaling
├── keycloak/                  # Identity and access management
├── kiali/                     # Istio service mesh visualization
├── lgtm/                      # LGTM observability stack (Loki, Grafana, Tempo, Mimir)
├── metrics-server/            # Kubernetes metrics server
├── open-webui/                # AI interface application
├── openclaw/                  # OpenClaw AI agents: values.yaml, argocd/ (operator, agents, ingress), agents/ (one CR per agent), ingress/ (Istio VS)
├── opentelemetry-kube-stack/  # OpenTelemetry configuration
├── strimzi/                   # Kafka operator
├── deployment.yaml            # Root ArgoCD application (deploys all applications)
├── renovate.json             # Renovate configuration for automated dependency updates
└── */values.yaml              # Helm values for each service
```

## 🔧 Configuration Highlights

### Cluster Architecture
- **Control Plane**: 3-node control plane with stacked etcd on Proxmox VMs
- **Talos Linux**: Immutable, API-driven operating system
- **Cloud Provider**: Proxmox with CCM, CSI, and Karpenter integration
- **Auto-scaling**: Karpenter with dynamic node provisioning from Proxmox templates
- **Dual Stack**: IPv6/IPv4 support with native routing
- **CNI**: Cilium with eBPF host routing (kubeProxyReplacement), BGP integration, DSR mode, and advanced BPF features
- **Networking**: Native routing with BGP, load balancer IP pools, pod CIDR management, and eBPF datapath (netkit)

### Storage Strategy
- **Proxmox CSI**: Native Proxmox block storage provisioner
- **AIStor**: S3-compatible object storage with MinKMS key management
- **CloudNativePG**: PostgreSQL databases
- **NFS CSI**: Network file system support

### Security Features
- **mTLS**: Service-to-service encryption via Istio Ambient Mode
- **Zero-Trust**: Istio ambient mode provides security without sidecars
- **OIDC**: Single sign-on with Keycloak
- **Certificate Automation**: Let's Encrypt with Route53
- **RBAC**: Role-based access control

### Observability Stack
- **LGTM**: Loki (distributed logs), Grafana (visualization), Tempo (distributed traces), Mimir (distributed metrics)
- **OpenTelemetry Kube Stack**: Standardized telemetry collection with automated instrumentation, metrics collection, and export to LGTM stack (replaces Prometheus stack)
- **ELK**: Elasticsearch, Kibana for advanced log analytics
- **Kiali**: Service mesh visualization
- **Metrics Server**: Kubernetes metrics API for HPA and VPA

## 🤝 Contributing

1. All changes should be made via pull requests
2. ArgoCD automatically syncs approved changes
3. Renovate handles dependency updates
4. Test changes in staging environment first

## 📚 Documentation & Resources

### Official Documentation
- [Talos Linux Documentation](https://www.talos.dev/docs/) - Immutable Kubernetes OS
- [Istio Service Mesh Guide](https://istio.io/latest/docs/) - Service mesh documentation
- [ArgoCD User Guide](https://argo-cd.readthedocs.io/) - GitOps continuous delivery
- [Cilium Documentation](https://docs.cilium.io/) - eBPF-based networking
- [Karpenter Documentation](https://karpenter.sh/) - Dynamic node provisioning
- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/) - Virtualization platform

### Learning Resources
- [CNCF Landscape](https://landscape.cncf.io/) - Cloud Native technology overview
- [Kubernetes Documentation](https://kubernetes.io/docs/) - Official Kubernetes docs
- [Terraform Documentation](https://www.terraform.io/docs) - Infrastructure as Code

### Related Projects
- [Talos Linux](https://github.com/siderolabs/talos) - Immutable Kubernetes OS
- [Istio](https://github.com/istio/istio) - Service mesh
- [ArgoCD](https://github.com/argoproj/argo-cd) - GitOps tool
- [Cilium](https://github.com/cilium/cilium) - eBPF networking

## 🚨 Important Notes

### Talos Linux Benefits
- **Immutable OS**: Read-only root filesystem prevents configuration drift
- **API-Driven**: All configuration managed through gRPC API
- **Minimal Attack Surface**: No SSH, package managers, or shell access
- **Atomic Updates**: Rolling updates with automatic rollback on failure
- **Declarative Configuration**: Infrastructure as code with Terraform
- **Proxmox Integration**: Seamless VM lifecycle management via Terraform
- **Automated Bootstrap**: Proxmox credentials automatically injected via inline manifests
- **Cloud-Ready**: Built-in cloud controller integration for node management

### Proxmox Integration
- **Automated Credentials**: CCM, CSI, and Karpenter credentials are generated by Terraform
- **Secrets Management**: All Proxmox API tokens stored securely via inline manifests
- **Dynamic Provisioning**: Karpenter uses Proxmox templates for on-demand node scaling
- **Storage Integration**: Proxmox CSI provides native block storage provisioning
- **Network Integration**: Cilium BGP enables advanced routing with Proxmox infrastructure

### Backup Strategy
- **AIStor / S3**: Object versioning and lifecycle policies (S3-compatible)
- **CloudNativePG**: Automated backups to object storage (e.g. AIStor S3)
- **Elasticsearch**: Snapshot backups to object storage (e.g. AIStor S3)
- **Proxmox CSI**: Native Proxmox storage snapshots

### Monitoring Alerts
- **OpenTelemetry Kube Stack**: Cluster and application metrics collection
- **Mimir**: Long-term metrics storage and alerting
- **Grafana**: Custom dashboards and alerting
- **Kiali**: Service mesh health monitoring

### Disaster Recovery
- **GitOps**: All configuration in version control
- **ArgoCD**: Self-healing and drift detection
- **Storage**: Distributed and replicated storage
- **Backups**: Automated backup strategies

---

## 🏷️ Topics & Tags

This project uses and demonstrates:

**Kubernetes Ecosystem**: `kubernetes` `talos-linux` `proxmox` `terraform` `infrastructure-as-code` `gitops` `argocd`

**Service Mesh & Networking**: `istio` `cilium` `ebpf` `bgp` `service-mesh` `zero-trust` `mtls`

**Observability**: `grafana` `loki` `tempo` `mimir` `opentelemetry` `kiali` `elasticsearch` `kibana` `lgtm-stack`

**Storage**: `aistor` `minkms` `minio` `s3` `cloudnative-pg` `postgresql` `nfs` `csi` `proxmox-csi`

**Security & Authentication**: `keycloak` `oidc` `oauth2` `cert-manager` `lets-encrypt` `rbac`

**Auto-scaling**: `karpenter` `keda` `autoscaling` `dynamic-scaling`

**CI/CD & Automation**: `argocd` `gitops` `renovate` `continuous-delivery`

**Applications**: `immich` `open-webui` `openclaw` `homepage` `n8n` `kafka` `strimzi`

**Infrastructure**: `homelab` `self-hosted` `cloud-native` `cncf` `production-ready`

---

Built with ❤️ using Cloud Native technologies
