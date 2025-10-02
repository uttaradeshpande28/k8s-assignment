# Kubernetes Assignment MVP

This project implements a complete Kubernetes solution with database, web server, monitoring, and security components as required for the assignment.

##  Architecture Overview

The solution consists of the following components:

- **MySQL Database**: StatefulSet with persistent storage
- **Nginx Web Server**: Deployment with 3 replicas and custom configuration
- **Pod Watcher**: Golang application monitoring pod lifecycle events
- **Network Policies**: Security rules restricting database access
- **Helm Charts**: Complete deployment automation

##  Requirements Fulfilled

###  Main Test Requirements
1. **Kubernetes Cluster**: Kind cluster for local development
2. **Database Cluster**: MySQL StatefulSet with persistent data
3. **Web Server**: Nginx with multiple replicas and custom configuration
4. **Pod IP Display**: Web page shows Pod IP address
5. **Serving Host**: Init container modifies serving-host field
6. **Network Security**: Network policies restrict database access
7. **Disaster Recovery**: Backup scripts and procedures
8. **Node Scheduling**: Node affinity for database placement

###  Golang Application
1. **Pod Monitoring**: Watches pod create/delete/update events
2. **Event Logging**: Logs all pod lifecycle changes
3. **Helm Deployment**: Complete Helm chart for all components

###  Deliverables
1. **Design Documentation**: Architecture and network diagrams
2. **Helm Charts**: Complete deployment automation
3. **Source Code**: Golang monitoring application
4. **Dockerfiles**: Container images for all components
5. **Demo Access**: Working Kind cluster with instructions

##  Quick Start

### Prerequisites
- Docker Desktop or Kind
- kubectl
- Helm (optional, for Helm deployment)

### 1. Create Kind Cluster
`ash
# Install Kind (if not already installed)
curl -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.20.0/kind-windows-amd64
move kind-windows-amd64.exe kind.exe

# Create cluster
kind create cluster --name k8s-assignment

# Verify cluster
kubectl get nodes
`

### 2. Deploy Components
`ash
# Create namespace
kubectl create namespace k8s-assignment

# Deploy MySQL
kubectl apply -f k8s-manifests/mysql-deployment.yaml

# Deploy Nginx
kubectl apply -f k8s-manifests/nginx-deployment.yaml

# Deploy Network Policies
kubectl apply -f k8s-manifests/network-policies.yaml

# Deploy Pod Watcher
kubectl apply -f k8s-manifests/pod-watcher.yaml
`

### 3. Access the Application
`ash
# Port forward to access web page
kubectl port-forward service/nginx-service 30080:80 -n k8s-assignment

# Open browser to http://localhost:30080
`

### 4. View Pod Watcher Logs
`ash
# Check pod watcher logs
kubectl logs -f daemonset/pod-watcher -n k8s-assignment
`

##  Project Structure

`
k8s-assignment/
 README.md                    # This file
 docs/                        # Documentation
    architecture.md          # Architecture details
 k8s-manifests/              # Kubernetes YAML files
    mysql-deployment.yaml    # MySQL StatefulSet
    nginx-deployment.yaml    # Nginx Deployment
    network-policies.yaml    # Network security
    pod-watcher.yaml        # Pod monitoring
 golang-monitor/              # Golang source code
    main.go                  # Pod watcher application
    go.mod                   # Go module file
    Dockerfile               # Container image
 helm-charts/                 # Helm charts
    k8s-assignment/          # Main Helm chart
        Chart.yaml           # Chart metadata
        values.yaml          # Configuration values
        templates/           # Helm templates
 scripts/                     # Utility scripts
`

##  Configuration

### Environment Variables
- NAMESPACE: Kubernetes namespace (default: k8s-assignment)
- MYSQL_ROOT_PASSWORD: MySQL root password
- MYSQL_PASSWORD: MySQL user password

### Resource Limits
- **MySQL**: 256Mi-512Mi RAM, 250m-500m CPU
- **Nginx**: 128Mi-256Mi RAM, 100m-200m CPU
- **Pod Watcher**: 64Mi-128Mi RAM, 50m-100m CPU

##  Security Features

### Network Policies
- **MySQL**: Only accessible from Nginx pods on port 3306
- **Nginx**: Accessible from external on port 80
- **DNS**: Allowed for service discovery

### RBAC
- **Pod Watcher**: ServiceAccount with minimal required permissions
- **ClusterRole**: Limited to pod watching only

##  Monitoring

### Pod Watcher Features
- **Real-time monitoring** of pod lifecycle events
- **Event logging** with timestamps
- **Namespace filtering** (k8s-assignment only)
- **Automatic reconnection** on connection loss

### Log Output Example
`
2025-10-01 16:30:15 [INFO] Pod CREATED: mysql-0 in namespace k8s-assignment
2025-10-01 16:30:20 [INFO] Pod CREATED: nginx-7f89cf47bf-25gxj in namespace k8s-assignment
2025-10-01 16:30:25 [INFO] Pod UPDATED: nginx-7f89cf47bf-25gxj in namespace k8s-assignment
`

##  Disaster Recovery

### Backup Strategy
- **Database Backup**: mysqldump script for data backup
- **Volume Persistence**: hostPath volumes survive pod restarts
- **Manual Restore**: Restore from backup files

### Backup Commands
`ash
# Create backup
kubectl exec mysql-0 -n k8s-assignment -- mysqldump -u root -p testdb > backup.sql

# Restore backup
kubectl exec -i mysql-0 -n k8s-assignment -- mysql -u root -p testdb < backup.sql
`

##  Networking

### Internal Connections
- **Web Server  Database**: Port 3306 (MySQL)
- **Pod Watcher  API Server**: HTTPS (Kubernetes API)

### External Access
- **Web Page**: http://localhost:30080 (NodePort)
- **Database**: Internal only (ClusterIP)

##  Production Considerations

### What's Implemented (MVP)
-  Basic Kubernetes cluster
-  Persistent database storage
-  Multi-replica web server
-  Pod monitoring and logging
-  Network security policies
-  Helm deployment automation

### What Would Be Added in Production
-  **High Availability**: Multi-node clusters
-  **Advanced Networking**: CNI plugins, Service Mesh
-  **Enterprise Monitoring**: Prometheus, Grafana
-  **Automated Backups**: Cross-region replication
-  **RBAC**: Role-based access control
-  **Resource Quotas**: CPU and memory limits
-  **Health Checks**: Liveness and readiness probes
-  **Rolling Updates**: Zero-downtime deployments

##  Troubleshooting

### Common Issues
1. **Kind cluster not starting**: Check Docker Desktop is running
2. **Pods not starting**: Check resource limits and node capacity
3. **Network policies blocking**: Verify pod labels match selectors
4. **Pod watcher not logging**: Check RBAC permissions

### Debug Commands
`ash
# Check pod status
kubectl get pods -n k8s-assignment

# Check pod logs
kubectl logs <pod-name> -n k8s-assignment

# Check network policies
kubectl get networkpolicies -n k8s-assignment

# Check services
kubectl get services -n k8s-assignment
`

##  License

This project is created for educational purposes as part of a Kubernetes assignment.

##  Author

Created by Uttara Deshpande for Kubernetes assignment submission.

---

**Note**: This is an MVP implementation focused on demonstrating core Kubernetes concepts. For production use, additional security, monitoring, and operational features would be required.

