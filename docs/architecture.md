# Kubernetes Assignment Architecture

## Overview
This MVP implements a complete Kubernetes solution with database, web server, monitoring, and security components deployed on AWS EKS.

## Current MVP Implementation

### 1. Kubernetes Cluster
- **AWS EKS**: Managed Kubernetes cluster
- **Namespace**: k8s-assignment
- **CNI**: AWS VPC CNI (Network Policies not enforced by default)

### 2. Database Layer
- **MySQL Deployment**: Single replica with persistent storage
- **MySQL Service**: ClusterIP service on port 3306
- **Secrets**: MySQL credentials stored in Kubernetes secrets
- **Resource Limits**: 256Mi-512Mi RAM, 250m-500m CPU

### 3. Web Server Layer
- **Nginx Deployment**: 3 replicas for high availability
- **Nginx Service**: NodePort service (port 30080) for external access
- **Init Container**: Generates dynamic HTML with Pod IP and Serving Host
- **ConfigMap**: Custom Nginx configuration mounted
- **Dynamic Content**: Shows actual Pod IP and "Host-{last5chars}" format

### 4. Security Layer
- **Network Policies**: Configured to restrict database access to web server pods only
- **Port Restriction**: Only port 3306 allowed for database connections
- **Default Deny**: All other traffic blocked by default
- **RBAC**: ServiceAccount with minimal required permissions

### 5. Monitoring Layer
- **Pod Watcher**: DaemonSet using alpine/k8s image with kubectl --watch
- **Real-time Monitoring**: Detects pod create/delete/update events
- **Event Logging**: Logs pod lifecycle changes with timestamps
- **Namespace Filtering**: Monitors k8s-assignment namespace only

### 6. Deployment Layer
- **Helm Chart**: Complete deployment automation
- **Values Configuration**: Configurable parameters
- **Manifest Files**: Individual YAML files for direct deployment

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

## Architecture Diagram

`

                    AWS EKS Cluster                         

  Namespace: k8s-assignment                                  
                                                             
               
     Nginx            Nginx            Nginx          
     Pod 1            Pod 2            Pod 3          
                                                      
               
                                                         
                   
                                                           
                             
     MySQL                  Pod Watcher    
     Pod                                DaemonSet      
                             
                                                             
               
     ConfigMap        Secrets          Services       
     (nginx)          (mysql)          (nginx,        
                                        mysql)        
               

`

## Next Steps for Production

1. **Install Calico CNI** for Network Policy enforcement
2. **Deploy custom Golang pod watcher** with proper image registry
3. **Implement automated backups** with AWS RDS or custom scripts
4. **Add monitoring stack** (Prometheus, Grafana)
5. **Implement GitOps** workflow with ArgoCD
6. **Add security scanning** and compliance checks
7. **Set up multi-region** disaster recovery
8. **Implement resource quotas** and limits
