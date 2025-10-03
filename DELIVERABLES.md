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
**Location**: `helm-charts/`

**Contents:**
- Complete Helm charts for all components
- Configurable values.yaml files
- Templates for MySQL, Nginx, Pod Watchers, Network Policies
- Deployment automation
- Resource management

**Structure:**
```
helm-charts/
└── k8s-assignment/              # Single comprehensive chart
    ├── Chart.yaml
    ├── values.yaml
    ├── VERSION
    ├── templates/
    │   ├── mysql.yaml
    │   ├── nginx.yaml
    │   ├── pod-watcher.yaml
    │   └── network-policies.yaml
    └── image/
        ├── Dockerfile
        └── scripts/
            ├── main.go
            ├── go.mod
            └── go.sum
```

### **Source code Golang Applications**
**Location**: `helm-charts/k8s-assignment/image/scripts/`

**Contents:**
- Complete Golang pod monitoring application
- Real-time pod lifecycle event detection
- Kubernetes API integration
- Event logging with timestamps
- Namespace filtering

**Files:**
```
helm-charts/k8s-assignment/image/scripts/
├── main.go              # Main application code
├── go.mod               # Go module dependencies
└── go.sum               # Dependency checksums
```

## **Additional Supporting Files**

### **Kubernetes Manifests**
**Location**: `k8s-manifests/`

**Contents:**
- Individual YAML files for direct deployment
- MySQL StatefulSet with persistent storage
- Nginx Deployment with custom configuration
- Network Policies for security
- Automated backup CronJob

### **Documentation**
**Location**: `docs/`

**Contents:**
- Architecture design document
- Limitations and production strategies
- Implementation status and requirements analysis


## **Implementation Status**

### **Fully Implemented (8/10)**
1. **Kubernetes Cluster**: Deployed on existing EKS cluster
2. **Database Cluster**: MySQL StatefulSet with persistent data
3. **Web Server**: Nginx with 3 replicas and custom configuration
4. **Dynamic Web Page**: Pod IP and serving-host display working
5. **Golang Application**: Pod monitoring with real-time events
6. **Helm Charts**: Complete Helm charts for all components
7. **Custom Configuration**: Nginx config mounted from ConfigMap
8. **Init Container**: Dynamic serving-host field modification

### **Two Deployment Solutions Provided**

#### **Solution 1: kubectl Deployment**
- **Files**: `k8s-manifests/` folder
- **Monitoring**: Simple kubectl-based pod watcher (`alpine/k8s` image)
- **Deployment**: `kubectl apply -f k8s-manifests/`
- **Components**: MySQL, Nginx, Network Policies, Simple Pod Watcher

#### **Solution 2: Helm Deployment**
- **Files**: `helm-charts/k8s-assignment/` folder
- **Monitoring**: Custom Golang application with Kubernetes API integration
- **Deployment**: Single `helm install` command
- **Components**: MySQL, Nginx, Network Policies, Golang Pod Watcher

### **Partially Implemented (2/10)**
1. **Network Security**: Policies configured but not enforced on EKS
2. **Disaster Recovery**: Automated backup CronJob implemented

### **Not Implemented (Due to Limitations)**
1. **Multi-Region Setup**: Single cluster deployment
2. **Advanced Node Scheduling**: No node affinity implementation
3. **Custom CNI**: Cannot modify EKS CNI configuration

**For detailed limitations analysis and production strategies, see:**
- `docs/limitations-and-strategies.txt` - Comprehensive analysis
