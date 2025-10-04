# Kubernetes Assignment MVP

This project implements a complete Kubernetes solution with database, web server, monitoring, and security components as required for the assignment.

## Architecture Overview

The solution consists of the following components deployed on AWS EKS:

- **MySQL Database**: Single instance StatefulSet with persistent storage and secrets management
- **Nginx Web Server**: Deployment with 3 replicas, custom configuration, and dynamic content
- **Pod Watcher**: Real-time pod lifecycle monitoring using kubectl --watch and custom Golang application
- **Network Policies**: Security rules restricting database access (configured but not enforced on EKS)
- **Helm Charts**: Complete deployment automation

## Deployment Limitations and Workarounds Implemented

**EKS Access Limitation**: This solution was deployed on an existing AWS EKS cluster from the office environment due to security restrictions that prevented local installation of Docker Desktop, Kind, or Minikube. The EKS cluster was already established with the control plane, which is not available in AWS free tier. 

**Workaround**: While EKS access cannot be provided as it's a restricted cluster, the deployed solution can be demonstrated via screen share showing:
- Live pod status and logs
- Web page functionality with dynamic content
- Network connectivity tests
- Pod monitoring in real-time
- Helm deployment process

**Network Policy Limitation**: AWS EKS uses VPC CNI which doesn't enforce Network Policies by default. However, the manifests and Helm charts are correctly configured and would work in clusters with Calico or Cilium CNI.

## Current MVP Status

### Key Features Working
- **Kubernetes Cluster**: Deployed on existing EKS cluster
- **Persistent Database**: MySQL single instance with persistent data
- **Web Server**: Nginx with multiple replicas and custom configuration
- **Dynamic Web Page**: Shows Pod IP and "Host-{last5chars}" format
- **Pod Monitoring**: Real-time pod lifecycle event detection
- **Helm Deployment**: Complete deployment automation
- **Disaster Recovery**: Automated backup CronJob

## Prerequisites

- AWS EKS cluster access
- kubectl configured
- Helm (optional, for Helm deployment)
- Docker (for building Golang application)

## Two Deployment Approaches

### **Approach 1: Direct kubectl Deployment**
**What it contains**: Simple deployment using individual Kubernetes manifests with basic kubectl-based monitoring. Contains MySQL StatefulSet with persistent storage, Nginx deployment with 3 replicas and dynamic content generation, Network Policies for security, and a simple pod watcher using alpine/k8s image with kubectl --watch commands.

**Commands:**
```bash
# Deploy all components
kubectl apply -f k8s-manifests/

# Check status
kubectl get pods -n k8s-assignment

# Access web page
kubectl port-forward svc/nginx-service 8080:80 -n k8s-assignment

# Check simple pod watcher logs
kubectl logs -f deployment/pod-watcher -n k8s-assignment
```

**Components deployed:**
- MySQL (StatefulSet with persistent storage)
- Nginx (3 replicas with dynamic content)
- Network Policies (configured but not enforced on EKS)
- Simple Pod Watcher (kubectl --watch based monitoring)

### **Approach 2: Helm Deployment**
**What it contains**: Comprehensive Helm chart deployment with advanced Golang-based monitoring. Contains all components managed by Helm with parameterized configurations, custom Golang application for pod monitoring using Kubernetes client-go library, automated backup CronJob, and complete RBAC setup for secure API access.

**Commands:**
```bash
# Build Golang application using Dockerfile
cd helm-charts/k8s-assignment/image
docker build -t YOUR_REGISTRY/pod-watcher:latest .
docker push YOUR_REGISTRY/pod-watcher:latest

# Deploy with Helm
helm install k8s-assignment ./helm-charts/k8s-assignment \
  --set podWatcher.image.repository=YOUR_REGISTRY/pod-watcher \
  --set podWatcher.image.tag=latest \
  --namespace k8s-assignment

# Check Helm resources
kubectl get pods -n k8s-assignment | grep helm

# Access Helm web page
kubectl port-forward svc/nginx-service-helm 8081:80 -n k8s-assignment

# Check Golang pod watcher logs
kubectl logs -f deployment/pod-watcher-golang-helm -n k8s-assignment
```

**Components deployed:**
- MySQL (StatefulSet with persistent storage) - Helm managed
- Nginx (3 replicas with dynamic content) - Helm managed
- Network Policies (configured but not enforced on EKS) - Helm managed
- Golang Pod Watcher (Custom application with Kubernetes API integration)
- Automated Backup CronJob - Helm managed

## Two Different Approaches Comparison

| Feature | kubectl Approach | Helm Approach |
|---------|------------------|---------------|
| **Deployment** | Individual manifests | Single Helm chart |
| **Monitoring** | Simple kubectl --watch | Custom Golang application |
| **Configuration** | Static YAML files | Parameterized values.yaml |
| **Resource Management** | Manual | Automated with Helm |
| **Backup Strategy** | Manual scripts | Automated CronJob |
| **RBAC** | Basic | Advanced with ServiceAccount |
| **Scalability** | Manual scaling | Helm upgrade/downgrade |
| **Maintenance** | Manual updates | Version-controlled releases |

## Deliverables

1. **Design of the internal and external connections**: `docs/Design-of-internal-and-external-connections.md`
2. **Helm-charts**: `helm-charts/k8s-assignment/`
3. **Source code Golang Applications**: `helm-charts/k8s-assignment/image/scripts/main.go`
4. **Dockerfiles**: `helm-charts/k8s-assignment/image/Dockerfile`

## Suggested Solutions for Assignment Requirements

**1. Find a flexible way to connect the Pod to a new network other than the Pods networks with proper routes**

**Suggested Solutions**: Ways to connect pods to networks otherthan the default pod network, without requiring LoadBalancer services:

**Host Network Mode**: Pods use the host's network interface instead of the default pod network. This allows pods to access external networks directly through the host's network stack and routing table. Pods can communicate with external services using the host's IP address and custom routing rules.

**Custom CNI with Multiple Networks**: Using CNI plugins like Multus, pods can have multiple network interfaces attached. Each interface connects to a different network segment, allowing pods to communicate across multiple networks simultaneously. This creates flexible connectivity to external networks while maintaining pod network functionality.

**Service Mesh Virtual Networks**: Service mesh solutions like Istio create virtual network layers on top of the physical network. These virtual networks have their own routing rules, allowing pods to communicate through custom network paths and connect to external services through virtual network segments.

**Benefits**: Flexible connectivity to external networks, custom routing paths, and no LoadBalancer dependency.

**2. Find a way to allow the deployment engineer to schedule specific replicas of the database cluster on specific k8s nodes**

**Suggested Solutions**: Methods to control pod placement on specific nodes:

**Node Selector**: Direct pod scheduling based on node labels for hardware-specific placement (e.g., SSD storage, high-memory nodes).

**Node Affinity Rules**: Advanced scheduling using affinity and anti-affinity rules to distribute database replicas across availability zones, regions, or node types.

**Pod Anti-Affinity**: Ensure database pods are separated across different nodes for high availability and fault tolerance.

**Benefits**: Hardware optimization for database performance, improved availability through multi-zone deployment, and compliance with data placement requirements.

**3. Suggest a Disaster recovery solution for the DB**

**Implemented Solution**: Automated MySQL backup with CronJob

**How it works**: Our solution includes a CronJob that performs automated daily backups of the MySQL database. The backup runs at 2:00 AM UTC daily, storing compressed backup files in a persistent volume. The system supports manual backup triggers and provides restore capabilities from stored backups.

**Additional Suggested Solutions**:

**Cross-Region Replication**: Set up MySQL master-slave replication where the slave database runs in a different AWS region. This provides geographic diversity and protects against regional outages. The slave can be promoted to master during disaster scenarios.

**Multi-AZ Deployment Backup**: Deploy MySQL StatefulSet across multiple availability zones within the same region. Use Kubernetes PodAntiAffinity rules to ensure pods are distributed across different AZs, providing automatic failover and data redundancy.

**Cloud Storage Integration**: Backup files can be automatically uploaded to cloud storage services (AWS S3, Google Cloud Storage) for long-term retention and recovery. This provides cost-effective storage and easy restoration from any location.

**Database Clustering**: Implement MySQL cluster solutions like MySQL NDB Cluster or Percona XtraDB Cluster for active-active replication across multiple nodes, providing automatic failover and zero data loss.

**Benefits**: Automated daily backups, persistent storage for backup retention, manual backup capability, simple restore process, geographic redundancy, automatic failover, and long-term backup storage options.


## Project Configurations

### Environment Variables
- NAMESPACE: Kubernetes namespace (default: k8s-assignment)
- MYSQL_ROOT_PASSWORD: MySQL root password (from secrets)
- MYSQL_PASSWORD: MySQL user password (from secrets)

### Resource Limits
- **MySQL**: 256Mi-512Mi RAM, 250m-500m CPU
- **Nginx**: 128Mi-256Mi RAM, 100m-200m CPU
- **Pod Watcher**: 64Mi-128Mi RAM, 50m-100m CPU

## Security Features

### Network Policies
- **MySQL**: Only accessible from Nginx pods on port 3306
- **Nginx**: Accessible from external on port 80
- **Default Deny**: All other traffic blocked
- **DNS**: Allowed for service discovery

### RBAC
- **Pod Watcher**: ServiceAccount with minimal required permissions
- **ClusterRole**: Limited to pod watching only

## Monitoring

### Pod Watcher Features
- **Real-time monitoring** of pod lifecycle events
- **Event logging** with timestamps
- **Namespace filtering** (k8s-assignment only)
- **Automatic reconnection** on connection loss

### Log Output Example
```
2025/10/03 18:20:38 [2025-10-03 18:20:38] Pod CREATED: mysql-helm-0 in namespace k8s-assignment
2025/10/03 18:20:38 [2025-10-03 18:20:38] Pod CREATED: nginx-helm-75fd7db7cd-468n8 in namespace k8s-assignment
2025/10/03 18:20:38 [2025-10-03 18:20:38] Pod UPDATED: pod-watcher-golang-helm-7f9f7bb775-l9tgt in namespace k8s-assignment
```

## Backup Strategy with CronJob

### Automated Backup Implementation
Our solution includes an automated CronJob that performs daily MySQL backups:

**CronJob Configuration:**
- **Schedule**: Daily at 2:00 AM UTC
- **Storage**: Persistent Volume Claim for backup files
- **Retention**: Configurable backup retention policy
- **Compression**: Automatic gzip compression of backup files

### Backup Commands

**Deploy Backup CronJob:**
```bash
kubectl apply -f k8s-manifests/mysql-backup-cronjob.yaml
```

**Check CronJob Status:**
```bash
kubectl get cronjobs -n k8s-assignment
kubectl get jobs -n k8s-assignment
```

**Manual Backup Execution:**
```bash
# Create manual backup job
kubectl create job --from=cronjob/mysql-backup-cronjob-helm manual-backup-$(date +%Y%m%d) -n k8s-assignment

# Check backup job logs
kubectl logs job/manual-backup-$(date +%Y%m%d) -n k8s-assignment
```

**Restore from Backup:**
```bash
# List available backups
kubectl exec -it mysql-helm-0 -n k8s-assignment -- ls -la /backup/

# Restore specific backup
kubectl exec -it mysql-helm-0 -n k8s-assignment -- mysql -u root -p testdb < /backup/backup-2025-10-03.sql
```

**Backup Management:**
```bash
# Check backup PVC usage
kubectl get pvc mysql-backup-pvc-helm -n k8s-assignment

# Scale backup retention
kubectl patch cronjob mysql-backup-cronjob-helm -n k8s-assignment -p '{"spec":{"successfulJobsHistoryLimit":7}}'
```

## Troubleshooting

### Common Issues
1. **Pods not starting**: Check resource limits and node capacity
2. **Network policies not enforced**: Expected on EKS with AWS VPC CNI
3. **Pod watcher not logging**: Check RBAC permissions
4. **Web page not accessible**: Use port forwarding for access
5. **MySQL connection issues**: Verify network policies and service connectivity

### Debug Commands
```bash
# Check pod status
kubectl get pods -n k8s-assignment

# Check pod logs
kubectl logs <pod-name> -n k8s-assignment

# Check network policies
kubectl get networkpolicies -n k8s-assignment

# Check services
kubectl get services -n k8s-assignment

# Check pod watcher logs
kubectl logs deployment/pod-watcher-golang-helm -n k8s-assignment --follow

# Access web page
kubectl port-forward svc/nginx-service-helm 8080:80 -n k8s-assignment

# Test network connectivity
kubectl exec -it deployment/nginx -n k8s-assignment -- curl -v --connect-timeout 5 telnet://mysql.k8s-assignment.svc.cluster.local:3306 2>&1 | grep -E "(Connected|Failed|Connection)"
`

## Author

Created by Uttara Deshpande for Kubernetes assignment submission.

---

**Note**: This is an MVP implementation focused on demonstrating core Kubernetes concepts. The solution is fully functional and meets all assignment requirements. The Network Policy manifests are correctly configured and would work in a cluster with proper CNI support. Web page access is achieved through port forwarding, which is a standard Kubernetes practice for development and testing.