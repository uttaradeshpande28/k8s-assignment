# Kubernetes Assignment Architecture

## Architecture Diagram

### Visual Architecture Overview
```
┌─────────────────────────────────────────────────────────────────┐
│                        AWS EKS Cluster                         │
├─────────────────────────────────────────────────────────────────┤
│                    k8s-assignment Namespace                    │
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────┐ │
│  │   Web Layer     │    │ Database Layer  │    │Monitoring   │ │
│  │                 │    │                 │    │   Layer     │ │
│  │ ┌─────────────┐ │    │ ┌─────────────┐ │    │             │ │
│  │ │Nginx Pod 1  │ │    │ │MySQL Pod    │ │    │ ┌─────────┐ │ │
│  │ │<Pod IP>     │ │    │ │mysql-0      │ │    │ │Pod      │ │ │
│  │ └─────────────┘ │    │ │<Pod IP>     │ │    │ │Watcher  │ │ │
│  │                 │    │ └─────────────┘ │    │ └─────────┘ │ │
│  │ ┌─────────────┐ │    │                 │    │             │ │
│  │ │Nginx Pod 2  │ │    │ ┌─────────────┐ │    │ ┌─────────┐ │ │
│  │ │<Pod IP>     │ │    │ │MySQL Service│ │    │ │Golang   │ │ │
│  │ └─────────────┘ │    │ │ClusterIP:3306│ │    │ │Watcher  │ │ │
│  │                 │    │ └─────────────┘ │    │ └─────────┘ │ │
│  │ ┌─────────────┐ │    │                 │    │             │ │
│  │ │Nginx Pod 3  │ │    │                 │    │             │ │
│  │ │<Pod IP>     │ │    │                 │    │             │ │
│  │ └─────────────┘ │    │                 │    │             │ │
│  │                 │    │                 │    │             │ │
│  │ ┌─────────────┐ │    │                 │    │             │ │
│  │ │Nginx Service│ │    │                 │    │             │ │
│  │ │NodePort:30080│ │    │                 │    │             │ │
│  │ └─────────────┘ │    │                 │    │             │ │
│  └─────────────────┘    └─────────────────┘    └─────────────┘ │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                Security Layer (Network Policies)            │ │
│  │                                                             │ │
│  │ • MySQL Policy: Only Nginx pods can access port 3306       │ │
│  │ • Nginx Policy: External access allowed on port 80         │ │
│  │ • Default Deny: All other traffic blocked                  │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                        External Access                         │
│                                                                 │
│  User Browser ──→ kubectl port-forward ──→ Nginx Service       │
│  http://<External IP>:80 or localhost:8080                     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                          Storage Layer                          │
│                                                                 │
│  MySQL Pod ──→ Persistent Volume Claim ──→ Persistent Volume   │
│  (mysql-0)      (10Gi Storage)           (AWS EBS)            │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   Deployment Layer                         │
│                                                                 │
│  kubectl Manifests     │     Helm Charts                      │
│  Direct YAML files     │     Templated deployment             │
│  Simple monitoring     │     Advanced Golang monitoring       │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow Architecture
```
1. External Access:
   Browser → Port Forward → Nginx Service → Nginx Pods

2. Database Access:
   Nginx Pods → MySQL Service → MySQL Pod → Persistent Storage

3. Monitoring:
   Pod Watchers → Monitor All Pods → Log Events

4. Security:
   Network Policies → Control Traffic Flow → Enforce Rules
```

## Component Architecture

### Web Layer Components
- **Nginx Deployment**: 3 replicas running on different nodes
- **Custom Configuration**: Mounted from ConfigMap
- **Init Container**: Generates dynamic content (Pod IP + serving-host)
- **Nginx Service**: NodePort for external access
- **Dynamic Content**: Shows Pod IP and "Host-{last5chars}" format

### Database Layer Components
- **MySQL StatefulSet**: Single instance with persistent storage
- **MySQL Service**: ClusterIP service on port 3306
- **Persistent Storage**: EBS volume via PVC
- **Secrets Management**: Passwords stored in Kubernetes secrets

### Monitoring Layer Components
- **Pod Watcher**: Real-time pod lifecycle monitoring
- **Simple Monitoring**: kubectl-based watcher using alpine/k8s
- **Advanced Monitoring**: Custom Golang application with Kubernetes API
- **Event Logging**: Timestamped pod create/delete/update events

### Security Layer Components
- **Network Policies**: Traffic flow control between components
- **MySQL Network Policy**: Restricts access to nginx pods only
- **Nginx Network Policy**: Allows external access
- **Default Deny Policy**: Blocks all unauthorized traffic

## Network Architecture

### Internal Connections
```
Web Server Pods (3 replicas)
      (port 3306)
MySQL Service → MySQL Pod (1 replica)
```

### Storage Components
```
MySQL Pod
      (Persistent Volume Claim)
EBS Volume (AWS managed - 10Gi)
```

### External Connections
```
Browser
      (NodePort 30080)
Nginx Service
      (ClusterIP)
Web Server Pods
```

### Service Discovery
- **ClusterIP Services**: Internal communication between pods
- **DNS Resolution**: Pods resolve service names automatically
- **Load Balancing**: Service distributes traffic across pod replicas

## Deployment Architecture

### Two Deployment Approaches

#### kubectl Direct Deployment
```
k8s-manifests/
├── mysql-kubectl.yaml           # MySQL StatefulSet
├── nginx-kubectl.yaml           # Nginx Deployment
├── network-policies-kubectl.yaml # Security policies
├── pod-watcher-kubectl.yaml     # Simple monitoring
└── mysql-backup-cronjob.yaml    # Automated backups
```

#### Helm Chart Deployment
```
helm-charts/k8s-assignment/
├── Chart.yaml                   # Chart metadata
├── values.yaml                  # Configuration parameters
├── templates/
│   ├── mysql.yaml               # Templated StatefulSet
│   ├── nginx.yaml               # Templated Deployment
│   ├── pod-watcher.yaml         # Templated monitoring
│   └── network-policies.yaml    # Templated policies
└── image/
    ├── Dockerfile               # Golang application build
    └── scripts/main.go          # Source code
```

## Security Architecture

### Network Security Model
- **MySQL Policy**: Only nginx pods can access port 3306
- **Nginx Policy**: External access allowed on port 80
- **Default Deny Policy**: All unauthorized traffic blocked
- **DNS Access**: Allowed for service discovery

### RBAC Security Model
- **ServiceAccount**: Minimal permissions for pod watcher
- **ClusterRole**: Limited to pod watching permissions only
- **ClusterRoleBinding**: Associates permissions with service account

### Secret Management
- **Kubernetes Secrets**: MySQL passwords encrypted in etcd
- **Base64 Encoding**: Password encoding in YAML files
- **Pod Mounting**: Secrets mounted as environment variables

---

**For detailed implementation status, deployment instructions, and requirements analysis, see:**
- `README.md` - Complete project overview and quick start guide
- `DELIVERABLES.md` - Implementation status and deliverables