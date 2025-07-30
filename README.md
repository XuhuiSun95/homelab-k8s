# Homelab Kubernetes Cluster

A comprehensive cloud-native homelab built on Kubernetes with GitOps, service mesh, observability, and AI capabilities.

## 🏗️ Architecture Overview

This homelab deploys a production-ready Kubernetes cluster using:
- **Infrastructure**: Kubespray for Kubernetes deployment with kube-vip, MetalLB, and cert-manager
- **GitOps**: ArgoCD for declarative application management
- **Service Mesh**: Istio for traffic management, security, and observability
- **Ingress**: Custom domain (`local-v2.xuhuisun.com`) with Let's Encrypt certificates
- **Storage**: Multiple storage solutions (Rook-Ceph, MinIO, NFS, CloudNativePG)
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

### 1. Initial Kubernetes Cluster Setup

Deploy Kubernetes using Kubespray:

```bash
# Pull Kubespray container
docker pull quay.io/kubespray/kubespray:v2.28.0

# Run Kubespray deployment
docker run --rm -it \
  --mount type=bind,source="$(pwd)"/ansible/inventory/myculster,dst=/inventory \
  --mount type=bind,source="${HOME}"/.ssh/id_rsa,dst=/root/.ssh/id_rsa \
  quay.io/kubespray/kubespray:v2.28.0 bash

# Deploy cluster
ansible-playbook -i /inventory/inventory.ini \
  --private-key /root/.ssh/id_rsa cluster.yml \
  -u esun-local -b
```

### 2. Bootstrap ArgoCD

Deploy ArgoCD manually for the first time (it will self-manage afterwards):

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm upgrade --install argocd argo/argo-cd \
  --values=argocd/values.yaml \
  --namespace=argocd \
  --create-namespace
```

### 3. Required Secrets Setup

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

### 4. Deploy All Applications

Deploy the entire stack using GitOps:

```bash
kubectl apply -f deployment.yaml
```

This single command deploys all applications in the correct order using ArgoCD sync waves.

## 🔑 Access Credentials

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
```bash
# Graceful cluster upgrade using Kubespray
ansible-playbook -i /inventory/inventory.ini \
  --private-key /root/.ssh/id_rsa upgrade-cluster.yml \
  -u esun-local -b
```

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

## 📁 Repository Structure

```
├── ansible/                    # Kubespray inventory and configuration
│   └── inventory/myculster/    # Cluster inventory and group vars
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
├── kubespray/                 # Kubernetes cluster deployment
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
- **Control Plane**: 3 nodes with stacked etcd
- **System Pool**: 3 dedicated nodes for system workloads
- **User Pool**: 6 nodes for user applications
- **Dual Stack**: IPv6/IPv4 support throughout
- **Node Affinity**: Proper workload placement with taints/tolerations

### Storage Strategy
- **Rook-Ceph**: Primary distributed storage
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

## 🤝 Contributing

1. All changes should be made via pull requests
2. ArgoCD automatically syncs approved changes
3. Renovate handles dependency updates
4. Test changes in staging environment first

## 📚 Documentation

- [Kubespray Documentation](./kubespray/docs/)
- [Istio Service Mesh Guide](https://istio.io/latest/docs/)
- [ArgoCD User Guide](https://argo-cd.readthedocs.io/)
- [CNCF Landscape](https://landscape.cncf.io/) for technology choices

## 🚨 Important Notes

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
