#!/bin/bash

# Kubernetes Assignment Setup Script
# This script sets up the complete Kubernetes assignment environment

set -e

echo " Starting Kubernetes Assignment Setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "[INFO] "
}

print_warning() {
    echo -e "[WARNING] "
}

print_error() {
    echo -e "[ERROR] "
}

# Check if kubectl is installed
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    print_status "kubectl is installed"
}

# Check if kind is installed
check_kind() {
    if ! command -v kind &> /dev/null; then
        print_warning "kind is not installed. Installing kind..."
        # Download and install kind
        curl -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.20.0/kind-windows-amd64
        move kind-windows-amd64.exe kind.exe
        print_status "kind installed successfully"
    else
        print_status "kind is already installed"
    fi
}

# Create kind cluster
create_cluster() {
    print_status "Creating kind cluster..."
    kind create cluster --name k8s-assignment
    print_status "Cluster created successfully"
}

# Create namespace
create_namespace() {
    print_status "Creating namespace..."
    kubectl create namespace k8s-assignment
    print_status "Namespace created successfully"
}

# Deploy MySQL
deploy_mysql() {
    print_status "Deploying MySQL..."
    kubectl apply -f k8s-manifests/mysql-deployment.yaml
    print_status "MySQL deployment started"
    
    # Wait for MySQL to be ready
    print_status "Waiting for MySQL to be ready..."
    kubectl wait --for=condition=ready pod -l app=mysql -n k8s-assignment --timeout=300s
    print_status "MySQL is ready"
}

# Deploy Nginx
deploy_nginx() {
    print_status "Deploying Nginx..."
    kubectl apply -f k8s-manifests/nginx-deployment.yaml
    print_status "Nginx deployment started"
    
    # Wait for Nginx to be ready
    print_status "Waiting for Nginx to be ready..."
    kubectl wait --for=condition=ready pod -l app=nginx -n k8s-assignment --timeout=300s
    print_status "Nginx is ready"
}

# Deploy Network Policies
deploy_network_policies() {
    print_status "Deploying Network Policies..."
    kubectl apply -f k8s-manifests/network-policies.yaml
    print_status "Network policies deployed"
}

# Deploy Pod Watcher
deploy_pod_watcher() {
    print_status "Deploying Pod Watcher..."
    kubectl apply -f k8s-manifests/pod-watcher.yaml
    print_status "Pod watcher deployed"
}

# Show deployment status
show_status() {
    print_status "Deployment Status:"
    echo ""
    kubectl get pods -n k8s-assignment
    echo ""
    kubectl get services -n k8s-assignment
    echo ""
    kubectl get networkpolicies -n k8s-assignment
}

# Show access instructions
show_access() {
    print_status "Access Instructions:"
    echo ""
    echo " Web Application:"
    echo "   kubectl port-forward service/nginx-service 30080:80 -n k8s-assignment"
    echo "   Then open: http://localhost:30080"
    echo ""
    echo " Pod Watcher Logs:"
    echo "   kubectl logs -f daemonset/pod-watcher -n k8s-assignment"
    echo ""
    echo " MySQL Access:"
    echo "   kubectl exec -it mysql-0 -n k8s-assignment -- mysql -u root -p"
    echo ""
}

# Main execution
main() {
    print_status "Starting setup process..."
    
    check_kubectl
    check_kind
    create_cluster
    create_namespace
    deploy_mysql
    deploy_nginx
    deploy_network_policies
    deploy_pod_watcher
    
    print_status "Setup completed successfully!"
    echo ""
    show_status
    echo ""
    show_access
}

# Run main function
main "$@"
