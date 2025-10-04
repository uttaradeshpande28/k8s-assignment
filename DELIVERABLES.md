# Kubernetes Assignment Deliverables

## **Assignment Deliverables**

### **Design of the internal and external connections**
**Location**: `docs/Design-of-internal-and-external-connections.md`

**Contents:**
- Complete architecture diagram (ASCII art)
- Internal pod-to-pod connections
- External access patterns
- Network flow diagrams
- Service discovery mechanisms
- Storage connections
- Security layer implementation

### **Helm-charts**
**Location**: `helm-charts/k8s-assignment/`

**Contents:**
- Complete Helm chart for all components (MySQL, Nginx, Pod Watcher, Network Policies)
- Configurable values.yaml with parameterized configurations
- Templates for StatefulSet, Deployment, Network Policies, RBAC
- Deployment automation with single Helm command
- Resource management and monitoring setup

**Structure:**
```
helm-charts/k8s-assignment/           # Single comprehensive chart
├── Chart.yaml                        # Helm chart metadata
├── values.yaml                       # Configurable parameters
├── VERSION                           # Chart version tracking
├── templates/
│   ├── mysql.yaml                    # MySQL single instance StatefulSet with persistent storage
│   ├── nginx.yaml                    # Nginx Deployment with 3 replicas
│   ├── pod-watcher.yaml             # Golang pod monitoring application
│   └── network-policies.yaml        # Network security policies
└── image/
    ├── Dockerfile                    # Multi-stage Docker build for Golang app
    └── scripts/
        ├── main.go                   # Golang source code
        ├── go.mod                    # Go module dependencies
        └── go.sum                    # Dependency checksums
```

### **Source code Golang Applications**
**Location**: `helm-charts/k8s-assignment/image/scripts/main.go`

**Contents:**
- Complete Golang pod monitoring application
- Real-time pod lifecycle event detection (Created/Deleted/Modified)
- Kubernetes client-go API integration
- Event logging with timestamps and pod names
- Namespace filtering for targeted monitoring
- RBAC integration with ServiceAccount and ClusterRole
- Automatic reconnection on connection loss

**Key Features Implemented:**
- Pod event watching (Add, Delete, Update)
- Structured logging with JSON format
- Kubernetes API server connection
- Error handling and graceful shutdown
- Containerized deployment ready

### **Dockerfiles**
**, Location**: `helm-charts/k8s-assignment/image/Dockerfile`

**Contents:**
- Multi-stage Docker build configuration
- Base image: `golang:1.21-alpine` for build stage
- Final image: `amazon/aws-cli:2.17.23` for runtime
- Go application compilation with CGO disabled
- Binary optimization for Linux containers
- Proper permissions and entrypoint configuration
- Ready for ECR push and Kubernetes deployment

### **Access to the cluster preferably or a working demo**

**Demo Access:**
- **Live EKS Cluster**: Deployed on existing AWS EKS cluster
- **Screen Share Capability**: Real-time demonstration of deployed components
- **Working Components**: 
  - MySQL database with persistent storage
  - Nginx web server with dynamic content (Pod IP + serving-host)
  - Real-time pod monitoring with event logging
  - Automated backup system with CronJob
  - Network policies configured (manifests provided)

**Demo Components Available:**
- Live pod status and logs
- Web page functionality with dynamic content
- Network connectivity demonstrations
- Backup and restore procedures
- Helm deployment process
- Pod creation/deletion event monitoring

**Note**: EKS cluster access cannot be provided directly as it's a restricted office environment, but all components can be demonstrated via screen share with real-time interaction and testing.

## **Additional Supporting Files**

### **Kubernetes Manifests**
**Location**: `k8s-manifests/`

**Contents:**
- Individual YAML files for direct kubectl deployment
- MySQL single instance StatefulSet with persistent storage
- Nginx Deployment with custom configuration and init containers
- Network Policies for security enforcement
- Simple pod watcher using alpine/k8s image
- Automated backup CronJob with PVC storage

### **Documentation**
**Location**: `docs/` and root files

**Contents:**
- Comprehensive README.md with complete setup instructions
- Architecture design document with network diagrams
- Implementation status and limitations analysis
- Two deployment approaches (kubectl vs Helm)
- Detailed troubleshooting guide
- Production considerations and strategies

## **Implementation Status**

### **Fully Implemented (8/10 Requirements)**

1. **Kubernetes Cluster**: Deployed on existing EKS cluster
2. **Persistent Database**: MySQL single instance StatefulSet with persistent data and automated backups
3. **Web Server**: Nginx with 3 replicas, custom configuration, and dynamic content
4. **Dynamic Web Page**: Shows Pod IP and "Host-{last5chars}" serving-host field
5. **Golang Application**: Real-time pod monitoring with Kubernetes API integration
6. **Helm Chart**: Single comprehensive chart deploying all components
7. **Custom Configuration**: Nginx config mounted from ConfigMap
8. **Disaster Recovery**: Automated backup CronJob (kubectl deployment only)

### **Suggested Solutions Provided**

**1. Flexible Network Connectivity**: 
- Host Network Mode, Custom CNI, Service Mesh approaches documented

**2. Node Scheduling**: 
- Node Selector, Node Affinity, Pod Anti-Affinity strategies explained

**3. Advanced Disaster Recovery**: 
- Cross-region replication, Multi-AZ deployment, Cloud storage integration

### **Two Deployment Solutions Provided**

#### **Solution 1: kubectl Deployment**
- **Files**: `k8s-manifests/` folder
- **Monitoring**: Simple kubectl-based pod watcher (`alpine/k8s` image)
- **Deployment**: `kubectl apply -f k8s-manifests/`
- **Components**: MySQL, Nginx, Network Policies, Simple Pod Watcher, Backup CronJob

#### **Solution 2: Helm Deployment**
- **Files**: `helm-charts/k8s-assignment/` folder
- **Monitoring**: Custom Golang application with Kubernetes API integration
- **Deployment**: Single `helm install` command
- **Components**: MySQL, Nginx, Network Policies, Golang Pod Watcher

### **Partially Implemented (2/10)**
1. **Network Security**: Policies configured but not enforced on EKS (AWS VPC CNI limitation)
2. **Custom Node Networks**: Concepts documented but not implemented due to cluster limitations

**Note**: All manifests and Helm charts are correctly configured and would work perfectly in clusters with proper CNI support (Calico/Cilium) or custom network configurations.

---

**This MVP successfully demonstrates all core Kubernetes concepts while providing production-ready deployment automation and comprehensive documentation for the complete assignment requirements.**