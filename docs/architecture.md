# Kubernetes Assignment Architecture

## Overview
This MVP implements a complete Kubernetes solution with database, web server, monitoring, and security components.

## Architecture Components

### 1. Kubernetes Cluster
- **Kind Cluster**: Single-node local development cluster
- **Namespace**: k8s-assignment
- **Storage**: hostPath persistent volumes

### 2. Database Layer
- **MySQL StatefulSet**: Single replica with persistent storage
- **MySQL Service**: ClusterIP service on port 3306
- **Persistent Volume**: hostPath storage for data persistence
- **ConfigMap**: MySQL configuration

### 3. Web Server Layer
- **Nginx Deployment**: 3 replicas for high availability
- **Nginx Service**: NodePort service for external access
- **Init Container**: Modifies serving-host field
- **ConfigMap**: Custom Nginx configuration
- **Custom Image**: Nginx with dynamic content showing Pod IP

### 4. Security Layer
- **Network Policy**: Restricts database access to web server pods only
- **Port Restriction**: Only port 3306 allowed for database connections

### 5. Monitoring Layer
- **Golang Pod Watcher**: DaemonSet monitoring pod lifecycle
- **Event Logging**: Logs pod create/delete/update events

### 6. Deployment Layer
- **Helm Chart**: Complete deployment automation
- **Values Configuration**: Configurable parameters

## Network Architecture

### Internal Connections
`
Web Server Pods (3 replicas)
     (port 3306)
MySQL Database Pod (1 replica)
     (persistent storage)
Host Path Volume
`

### External Connections
`
Browser
     (NodePort 30080)
Nginx Service
     (LoadBalancer)
Web Server Pods
`

## Security Model
- **Network Policies**: Web server pods can only connect to database on port 3306
- **All other traffic**: Denied to database
- **Pod-to-Pod**: Communication restricted by network policies

## Disaster Recovery
- **Database Backup**: mysqldump script for data backup
- **Volume Persistence**: hostPath volumes survive pod restarts
- **Manual Restore**: Restore from backup files

## Node Scheduling
- **Database Affinity**: Node affinity rules for database placement
- **Web Server**: Distributed across available nodes
- **Monitoring**: DaemonSet runs on all nodes

## Conceptual Extensions (Production)
- **Multi-node clusters**: High availability across multiple nodes
- **Advanced networking**: CNI plugins, Service Mesh
- **Enterprise backup**: Automated cross-region backups
- **Advanced monitoring**: Prometheus, Grafana, ELK stack
- **RBAC**: Role-based access control
- **Resource quotas**: CPU and memory limits
