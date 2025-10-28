# Homelab Kubernetes Cluster

A comprehensive cloud-native homelab built on Kubernetes with GitOps, service mesh, observability, and AI capabilities.

## 🏗️ Architecture Overview

This homelab deploys a production-ready Kubernetes cluster using:
- **Infrastructure**: Talos Linux on Proxmox VMs with Terraform for immutable Kubernetes deployment
- **Cloud Provider**: Proxmox integration with CCM, CSI, and Karpenter for automation
- **Networking**: Cilium CNI with BGP integration and dual-stack IPv4/IPv6 support
- **Auto-scaling**: Karpenter with Proxmox provider for dynamic node provisioning
- **GitOps**: ArgoCD for declarative application management
- **Service Mesh**: Istio for traffic management, security, and observability
- **Ingress**: Custom domain (`local-v2.xuhuisun.com`) with Let's Encrypt certificates
- **Storage**: Multiple storage solutions (Rook-Ceph, MinIO, NFS, CloudNativePG, Proxmox CSI)
- **Observability**: Complete LGTM stack (Loki, Grafana, Tempo, Mimir) plus ELK stack
- **Authentication**: Keycloak for identity and access management
- **Automation**: Renovate for dependency updates, KEDA for auto-scaling

## 📊 Services Dashboard

Access your services at [Homepage Dashboard](https://homepage.local-v2.xuhuisun.com)

### 🔐 Management & Security
| Service | URL | Purpose |
|---------|-----|---------|
| **ArgoCD** | https://argocd.local-v2.xuhuisun.com | GitOps continuous delivery |
| **Keycloak** | https://keycloak.local-v2.xuhuisun.com | Identity & access management |
| **Homepage** | https://homepage.local-v2.xuhuisun.com | Service dashboard |

### 📈 Observability & Monitoring
| Service | URL | Purpose |
|---------|-----|---------|
| **Grafana** | https://grafana.local-v2.xuhuisun.com | Metrics visualization |
| **Mimir** | https://mimir.local-v2.xuhuisun.com | Long-term metrics storage |
| **Kiali** | https://kiali.local-v2.xuhuisun.com | Istio service mesh console |
| **Kibana** | https://kibana.local-v2.xuhuisun.com | Elasticsearch visualization |

### 💾 Storage & Data
| Service | URL | Purpose |
|---------|-----|---------|
| **Rook-Ceph** | https://rook-ceph.local-v2.xuhuisun.com | Distributed storage management |
| **MinIO Console** | https://minio-console.local-v2.xuhuisun.com | Object storage management |

### 🤖 AI & Productivity
| Service | URL | Purpose |
|---------|-----|---------|
| **Open-WebUI** | https://open-webui.local-v2.xuhuisun.com | AI interface (LLM frontend) |
| **Immich** | https://immich.local-v2.xuhuisun.com | Photo management & backup |

### 🏠 Infrastructure
| Service | URL | Purpose |
|---------|-----|---------|
| **Proxmox VE** | https://pve2.local-v2.xuhuisun.com | Hypervisor management |
| **Proxmox Backup** | https://pbs.local-v2.xuhuisun.com | Backup management |
| **Scrypted** | https://scrypted.local-v2.xuhuisun.com | Home automation |

## 🚀 Deployment Categories

### API Gateway
- **Istio Ingress Gateway**: HTTP/HTTPS traffic routing with TLS termination
- **Certificate Management**: Automated Let's Encrypt certificates

### Cloud Native Storage
- **Rook-Ceph**: Distributed block, object, and file storage
- **MinIO**: S3-compatible object storage
- **CloudNativePG**: PostgreSQL operator for databases
- **NFS CSI Driver**: Network file system support

### Continuous Integration/Delivery
- **ArgoCD**: GitOps platform for Kubernetes deployments
- **Self-healing**: Automated drift detection and correction

### DNS & Network
- **External DNS**: Automated DNS record management with Unifi integration
- **Istio Service Mesh**: Advanced traffic management, security, and observability

### Observability Stack
- **LGTM Stack**: Complete observability with Loki, Grafana, Tempo, Mimir
- **LGTM Distributed**: Production-grade distributed LGTM deployment for scalability
- **OpenTelemetry Kube Stack**: Unified observability framework with automated instrumentation
- **Elastic Stack**: Elasticsearch, Kibana for log analytics
- **Kube-Prometheus**: Comprehensive cluster monitoring
- **Kiali**: Service mesh visualization

### Security & Compliance
- **Cert-Manager**: Automated certificate lifecycle management
- **Keycloak**: Enterprise identity and access management
- **OIDC Integration**: Single sign-on across services

### Service Mesh
- **Istio Base**: Core service mesh functionality
- **Istio CNI**: Network plugin for pod-to-pod encryption
- **Traffic Policies**: Advanced routing, load balancing, and circuit breaking

### Streaming & Messaging
- **Strimzi Kafka**: Apache Kafka on Kubernetes
- **OAuth Authentication**: Secured Kafka access via Keycloak

### Auto-scaling & Orchestration
- **KEDA**: Event-driven autoscaling for workloads

## 🛠️ Setup Instructions

### Prerequisites

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

# Configure Proxmox credentials (create credentials.auto.tfvars)
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

Deploy Cilium CNI with BGP integration and Proxmox cloud integrations:

```bash
# Add Helm repositories
helm repo add cilium https://helm.cilium.io/

# Install Cilium CNI with advanced networking features
helm upgrade -i cilium cilium/cilium --namespace kube-system --values files/cilium.yaml

# Apply Cilium BGP Configuration (for routing and load balancer IP pools)
kubectl apply -f files/cilium-bgp.yaml

# Install Talos Cloud Controller Manager
# Note: CCM credentials are automatically configured via inline manifests
helm upgrade -i talos-cloud-controller-manager oci://ghcr.io/siderolabs/charts/talos-cloud-controller-manager --namespace kube-system --values files/talos-ccm.yaml

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
```

### 3. Bootstrap ArgoCD

Deploy ArgoCD manually for the first time (it will self-manage afterwards):

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd \
  --values=argocd/values.yaml \
  --namespace=argocd \
  --create-namespace
```

### 4. Required Secrets Setup

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

#### NFS CSI Driver Configuration
```bash
kubectl create secret generic nfs-mount-options \
  --from-literal mountOptions="nolock" \
  --namespace kube-system
```

#### Proxmox Cloud Provider Credentials
The Proxmox credentials for CCM, CSI, and Karpenter are automatically configured during cluster bootstrap via inline manifests in Talos. No manual secret creation is needed for Proxmox integrations.

### 5. Deploy All Applications

Deploy the entire stack using GitOps:

```bash
kubectl apply -f deployment.yaml
```

This single command deploys all applications in the correct order using ArgoCD sync waves.

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

### Rook Ceph Dashboard Password
```bash
kubectl -n rook-ceph get secret rook-ceph-dashboard-password \
  -o jsonpath="{.data.password}" | base64 --decode | xclip
```

## 🔄 Maintenance & Upgrades

### Kubernetes Cluster Upgrade

Upgrade Talos Linux and Kubernetes:

```bash
# Navigate to terraform directory
cd terraform

# Update Talos version in terraform.tfvars
# release = "v1.8.0"  # Update to desired version

# Plan the upgrade
terraform plan

# Apply the upgrade (this will recreate VMs with new Talos version)
terraform apply

# Verify cluster is healthy after upgrade
talosctl get nodes
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

### Application Updates
- **Automated**: Renovate automatically creates PRs for Helm chart updates
- **Manual**: Update `targetRevision` in ArgoCD application manifests
- **Self-healing**: ArgoCD automatically syncs any configuration drift

## 🌐 Network Configuration

### Domain Structure
- **Primary Domain**: `local-v2.xuhuisun.com`
- **Wildcard Certificate**: `*.local-v2.xuhuisun.com` (Let's Encrypt)
- **DNS Provider**: Unifi with External DNS automation
- **TLS Termination**: Istio Ingress Gateway
- **BGP Integration**: Cilium BGP for LoadBalancer IP advertisement
- **Load Balancer IPs**: Managed via CiliumLoadBalancerIPPool resources

### Sync Wave Deployment Order
1. **Wave 30**: Core monitoring and telemetry (Prometheus, OpenTelemetry)
2. **Wave 41**: Auto-scaling (KEDA)
3. **Wave 42**: GitOps (ArgoCD)
4. **Wave 60**: Storage operators and service mesh (CNPG, Strimzi)
5. **Wave 70**: Applications and distributed services (LGTM, Keycloak, MinIO, Elastic)
6. **Wave 200**: User applications (Homepage, Open-WebUI, Immich)

## 🎯 Key Features

- **🔄 GitOps Workflow**: Everything managed as code with ArgoCD
- **🔒 Security First**: mTLS, OAuth2/OIDC, automated certificate management
- **📊 Full Observability**: Metrics, logs, traces, and service mesh visibility
- **🚀 Auto-scaling**: KEDA for event-driven scaling
- **💾 Multiple Storage**: Block, object, file, and database storage solutions
- **🤖 AI Ready**: Open-WebUI for LLM interactions
- **🏠 Home Integration**: Proxmox, Scrypted, and network infrastructure
- **⚡ Immutable Infrastructure**: Talos Linux provides immutable, API-driven OS
- **🔧 Infrastructure as Code**: Complete cluster lifecycle managed with Terraform
- **🛡️ Enhanced Security**: Minimal attack surface with read-only root filesystem
- **📦 Container-Optimized**: Built specifically for Kubernetes workloads
- **🔄 Dynamic Scaling**: Karpenter auto-scales nodes based on workload demand
- **🏷️ Node Pool Management**: Separate pools for system and user workloads

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
│   │   └── talos-ccm.yaml      # Talos Cloud Controller Manager
│   ├── templates/              # Talos configuration templates
│   │   ├── controlplane.yaml.tmpl # Control plane configuration (Proxmox integration)
│   │   ├── metadata.yaml.tmpl  # VM metadata template
│   │   └── worker.yaml.tmpl    # Worker node template for Karpenter
│   ├── terraform.tfvars        # Terraform variables (customize for your Proxmox)
│   ├── variables.tf            # Variable definitions
│   ├── outputs.tf              # Terraform outputs (kubeconfig, talosconfig, credentials)
│   ├── providers.tf            # Terraform provider configuration
│   ├── network.tf              # Network configuration and helpers
│   ├── talos-bootstrap.tf      # Talos cluster bootstrap and kubeconfig generation
│   ├── proxmox-kubenetes-token.tf # Proxmox API tokens for cloud providers
│   ├── proxmox-vm-cloud-image.tf  # Talos image management in Proxmox
│   ├── proxmox-vm-control-plane.tf # Control plane VM definitions
│   ├── proxmox-vm-worker-template.tf # Worker template for Karpenter
│   └── talos-image-factory.tf  # Talos image factory integration
├── argocd/                     # ArgoCD configuration and applications
│   ├── applications/           # Application definitions by category
│   │   ├── cloud-native-storage/ # Storage solutions
│   │   ├── continuous-integration-delivery/ # CI/CD tools
│   │   ├── dns/                # DNS management
│   │   ├── observability/      # Monitoring and logging
│   │   ├── scheduling-orchestration/ # Auto-scaling
│   │   ├── security-compliance/ # Security tools
│   │   ├── service-mesh/       # Istio components
│   │   ├── streaming-messaging/ # Kafka
│   │   └── user-defined-apps/  # Custom applications
│   └── values.yaml            # ArgoCD Helm values
├── cert-manager/              # Certificate management
├── cloudnative-pg/            # CloudNativePG operator configuration
├── csi-driver-nfs/            # NFS CSI driver configuration
├── eck/                       # Elastic Cloud on Kubernetes
├── external-dns/              # External DNS configuration
├── homepage/                  # Service dashboard
├── immich/                    # Photo management application
├── istio/                     # Service mesh configuration
├── keda/                      # Event-driven autoscaling
├── keycloak/                  # Identity and access management
├── kiali/                     # Istio service mesh visualization
├── kube-prometheus-stack/     # Prometheus monitoring stack
├── lgtm/                      # LGTM observability stack
├── lgtm-distributed/          # Distributed LGTM deployment
├── minio/                     # Object storage
├── open-webui/                # AI interface application
├── opentelemetry-kube-stack/  # OpenTelemetry configuration
├── rook-ceph/                 # Distributed storage
├── strimzi/                   # Kafka operator
└── */values.yaml              # Helm values for each service
```

## 📋 Current Application Versions

| Application | Version | Chart Repository |
|-------------|---------|------------------|
| ArgoCD | 8.1.3 | argo/argo-cd |
| Cert-Manager | v1.18.2 | jetstack/cert-manager |
| Istio | 1.26.2 | istio-release |
| Kube-Prometheus-Stack | 75.15.1 | prometheus-community |
| LGTM Distributed | 2.1.0 | grafana |
| OpenTelemetry Kube Stack | 0.7.0 | open-telemetry |
| Keycloak | 24.7.7 | bitnami/keycloak |
| Open-WebUI | 6.21.0 | openwebui |
| Homepage | 2.1.0 | jameswynn/helm-charts |
| Immich | 0.9.3 | immich |
| Rook-Ceph | v1.17.6 | rook-release |
| MinIO Operator | 7.1.1 | minio/operator |
| CloudNativePG | 0.24.0 | cnpg-system |
| CSI Driver NFS | 4.11.0 | csi-driver-nfs |
| Strimzi Kafka | 0.47.0 | strimzi |
| KEDA | 2.17.2 | kedacore |
| External DNS | 1.18.0 | external-dns |

## 🔧 Configuration Highlights

### Cluster Architecture
- **Control Plane**: 3-node control plane with stacked etcd on Proxmox VMs
- **Talos Linux**: Immutable, API-driven operating system
- **Cloud Provider**: Proxmox with CCM, CSI, and Karpenter integration
- **Auto-scaling**: Karpenter with dynamic node provisioning from Proxmox templates
- **Dual Stack**: IPv6/IPv4 support with native routing
- **CNI**: Cilium with BGP integration, DSR mode, and advanced BPF features
- **Networking**: Native routing with BGP, load balancer IP pools, and pod CIDR management

### Storage Strategy
- **Proxmox CSI**: Native Proxmox block storage provisioner
- **Rook-Ceph**: Distributed storage for high availability
- **MinIO**: S3-compatible object storage
- **CloudNativePG**: PostgreSQL databases
- **NFS CSI**: Network file system support

### Security Features
- **mTLS**: Service-to-service encryption via Istio
- **OIDC**: Single sign-on with Keycloak
- **Certificate Automation**: Let's Encrypt with Route53
- **RBAC**: Role-based access control

### Observability Stack
- **LGTM**: Loki (logs), Grafana (visualization), Tempo (traces), Mimir (metrics)
- **OpenTelemetry**: Standardized telemetry collection and export to LGTM stack
- **ELK**: Elasticsearch, Kibana for advanced log analytics
- **Prometheus**: Metrics collection and alerting
- **Kiali**: Service mesh visualization
- **Cilium Hubble**: Network and security observability

## 🤝 Contributing

1. All changes should be made via pull requests
2. ArgoCD automatically syncs approved changes
3. Renovate handles dependency updates
4. Test changes in staging environment first

## 📚 Documentation

- [Talos Linux Documentation](https://www.talos.dev/docs/)
- [Istio Service Mesh Guide](https://istio.io/latest/docs/)
- [ArgoCD User Guide](https://argo-cd.readthedocs.io/)
- [CNCF Landscape](https://landscape.cncf.io/) for technology choices

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
- **Rook-Ceph**: Built-in replication and snapshots
- **MinIO**: Object versioning and lifecycle policies
- **CloudNativePG**: Automated backups to MinIO
- **Elasticsearch**: Snapshot backups to MinIO

### Monitoring Alerts
- **Prometheus**: Cluster and application metrics
- **Grafana**: Custom dashboards and alerting
- **Kiali**: Service mesh health monitoring

### Disaster Recovery
- **GitOps**: All configuration in version control
- **ArgoCD**: Self-healing and drift detection
- **Storage**: Distributed and replicated storage
- **Backups**: Automated backup strategies

---

Built with ❤️ using Cloud Native technologies
