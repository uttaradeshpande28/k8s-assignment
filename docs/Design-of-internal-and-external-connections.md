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
│                        Helm Chart Layer                         │
│                                                                 │
│  Helm Values ──→ Helm Templates ──→ All Kubernetes Resources    │
│  (Config)        (Deployment)      (Pods, Services, Policies) │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow
```
1. User Access:
   Browser → Port Forward → Nginx Service → Nginx Pods

2. Database Access:
   Nginx Pods → MySQL Service → MySQL Pod → Persistent Storage

3. Monitoring:
   Pod Watchers → Monitor All Pods → Log Events

4. Security:
   Network Policies → Control Traffic Flow → Enforce Rules
```

## Overview
This MVP implements a complete Kubernetes solution with database, web server, monitoring, and security components deployed on an existing AWS EKS cluster from the office environment due to security restrictions preventing local setup.

## **Two Deployment Approaches**

### **Approach 1: kubectl Deployment**
- **Files**: `k8s-manifests/` folder
- **Monitoring**: Simple kubectl-based pod watcher using `alpine/k8s` image
- **Deployment**: Direct `kubectl apply` commands
- **Use Case**: Quick deployment, simple monitoring

### **Approach 2: Helm Deployment**
- **Files**: `helm-charts/k8s-assignment/` folder  
- **Monitoring**: Custom Golang application with Kubernetes API integration
- **Deployment**: Single Helm chart with templating and configuration
- **Use Case**: Production deployment, advanced monitoring

**For detailed implementation status and limitations analysis, see:**
- `DELIVERABLES.md` - Implementation status and deliverables overview
- `docs/limitations-and-strategies.txt` - Comprehensive analysis
- `README.md` - Project overview and quick start

## Network Architecture

### Internal Connections
`
Web Server Pods (3 replicas)
      (port 3306)
MySQL Database Pod (1 replica)
      (persistent storage)
EBS Volume (AWS managed)
`

### External Connections
`
Browser
      (NodePort 30080)
Nginx Service
      (ClusterIP)
Web Server Pods
`

## Security Model
- **Network Policies**: Web server pods can only connect to database on port 3306
- **All other traffic**: Denied to database by default-deny policy
- **Pod-to-Pod**: Communication restricted by network policies
- **RBAC**: Pod watcher has minimal required permissions

## Current MVP Status

###  Implemented and Working
- **Kubernetes Cluster**: AWS EKS cluster running
- **Database**: MySQL with persistent storage
- **Web Server**: Nginx with 3 replicas and custom configuration
- **Pod IP Display**: Shows actual pod IP address
- **Serving Host**: Shows "Host-{last5chars}" format
- **Init Container**: Modifies serving-host field dynamically
- **Custom Configuration**: Nginx config mounted from ConfigMap
- **Pod Monitoring**: Real-time pod lifecycle event detection
- **Network Policies**: Correctly configured (though not enforced on EKS)
- **Helm Charts**: Complete deployment automation

###  Platform Limitations
- **Network Policies**: Not enforced by AWS VPC CNI (requires Calico/Cilium)
- **Pod Watcher**: Using kubectl instead of custom Golang application
- **Disaster Recovery**: Manual backup procedures only

## Production-Level Enhancements

### 1. Advanced Networking
- **CNI Plugin**: Install Calico or Cilium to enforce Network Policies
- **Service Mesh**: Implement Istio for advanced traffic management
- **Multus CNI**: Multiple network interfaces for pod connectivity
- **Custom Routing**: Advanced routing rules and network segmentation

### 2. Enhanced Monitoring
- **Custom Golang Application**: Deploy the actual Go pod watcher
- **Prometheus**: Metrics collection and monitoring
- **Grafana**: Visualization and dashboards
- **ELK Stack**: Centralized logging
- **Alerting**: Automated alerts for pod failures

### 3. High Availability
- **Multi-AZ Deployment**: Deploy across multiple availability zones
- **Database Clustering**: MySQL cluster with replication
- **Load Balancing**: Application-level load balancing
- **Auto-scaling**: Horizontal Pod Autoscaler (HPA)

### 4. Security Enhancements
- **Pod Security Standards**: Implement pod security policies
- **Network Segmentation**: Advanced network isolation
- **Secrets Management**: External secrets management (AWS Secrets Manager)
- **Image Security**: Container image scanning and signing

### 5. Disaster Recovery
- **Automated Backups**: Scheduled database backups
- **Cross-Region Replication**: Multi-region disaster recovery
- **Point-in-Time Recovery**: Database restore capabilities
- **Backup Validation**: Automated backup testing

### 6. Operational Excellence
- **GitOps**: ArgoCD for continuous deployment
- **CI/CD Pipeline**: Automated testing and deployment
- **Resource Quotas**: Namespace-level resource limits
- **Health Checks**: Comprehensive liveness and readiness probes
- **Rolling Updates**: Zero-downtime deployments

## Next Steps for Complete Assignment Implementation

### **Assignment Requirements Not Fully Implemented:**

1. **Local Cluster Setup**
   - Deploy on local machine using Minikube, Kind, or Docker Desktop
   - Alternative: Use AWS EKS or other cloud Kubernetes service

2. **Network Policy Enforcement**
   - Install Calico CNI plugin for Network Policy enforcement
   - Alternative: Use cluster with built-in Network Policy support

3. **Disaster Recovery Implementation**
   - Implement automated database backup strategies
   - Set up backup validation and restore procedures

4. **Node Scheduling**
   - Implement node affinity rules for database pods
   - Configure pod placement on specific nodes

5. **Custom Network Implementation**
   - Deploy service mesh (Istio) for advanced networking
   - Implement custom routing and traffic management

6. **Golang Pod Watcher Enhancement**
   - Build and deploy custom Golang application
   - Push to container registry and integrate with Helm charts
