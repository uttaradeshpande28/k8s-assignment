# Kubernetes Assignment Setup Script (PowerShell)
# This script sets up the complete Kubernetes assignment environment

param(
    [switch],
    [switch]
)

# Colors for output
 = "Red"
 = "Green"
 = "Yellow"

# Function to print colored output
function Write-Status {
    param([string])
    Write-Host "[INFO] " -ForegroundColor 
}

function Write-Warning {
    param([string])
    Write-Host "[WARNING] " -ForegroundColor 
}

function Write-Error {
    param([string])
    Write-Host "[ERROR] " -ForegroundColor 
}

# Check if kubectl is installed
function Test-Kubectl {
    try {
        kubectl version --client | Out-Null
        Write-Status "kubectl is installed"
        return True
    }
    catch {
        Write-Error "kubectl is not installed. Please install kubectl first."
        return False
    }
}

# Check if kind is installed
function Test-Kind {
    try {
        kind version | Out-Null
        Write-Status "kind is already installed"
        return True
    }
    catch {
        if (-not ) {
            Write-Warning "kind is not installed. Installing kind..."
            # Download and install kind
             = "https://kind.sigs.k8s.io/dl/v0.20.0/kind-windows-amd64"
             = "kind.exe"
            Invoke-WebRequest -Uri  -OutFile 
            Write-Status "kind installed successfully"
            return True
        } else {
            Write-Error "kind is not installed and SkipKindInstall is set"
            return False
        }
    }
}

# Create kind cluster
function New-KindCluster {
    if (-not ) {
        Write-Status "Creating kind cluster..."
        kind create cluster --name k8s-assignment
        Write-Status "Cluster created successfully"
    } else {
        Write-Status "Skipping cluster creation"
    }
}

# Create namespace
function New-Namespace {
    Write-Status "Creating namespace..."
    kubectl create namespace k8s-assignment
    Write-Status "Namespace created successfully"
}

# Deploy MySQL
function Deploy-MySQL {
    Write-Status "Deploying MySQL..."
    kubectl apply -f k8s-manifests/mysql-deployment.yaml
    Write-Status "MySQL deployment started"
    
    # Wait for MySQL to be ready
    Write-Status "Waiting for MySQL to be ready..."
    kubectl wait --for=condition=ready pod -l app=mysql -n k8s-assignment --timeout=300s
    Write-Status "MySQL is ready"
}

# Deploy Nginx
function Deploy-Nginx {
    Write-Status "Deploying Nginx..."
    kubectl apply -f k8s-manifests/nginx-deployment.yaml
    Write-Status "Nginx deployment started"
    
    # Wait for Nginx to be ready
    Write-Status "Waiting for Nginx to be ready..."
    kubectl wait --for=condition=ready pod -l app=nginx -n k8s-assignment --timeout=300s
    Write-Status "Nginx is ready"
}

# Deploy Network Policies
function Deploy-NetworkPolicies {
    Write-Status "Deploying Network Policies..."
    kubectl apply -f k8s-manifests/network-policies.yaml
    Write-Status "Network policies deployed"
}

# Deploy Pod Watcher
function Deploy-PodWatcher {
    Write-Status "Deploying Pod Watcher..."
    kubectl apply -f k8s-manifests/pod-watcher.yaml
    Write-Status "Pod watcher deployed"
}

# Show deployment status
function Show-Status {
    Write-Status "Deployment Status:"
    Write-Host ""
    kubectl get pods -n k8s-assignment
    Write-Host ""
    kubectl get services -n k8s-assignment
    Write-Host ""
    kubectl get networkpolicies -n k8s-assignment
}

# Show access instructions
function Show-Access {
    Write-Status "Access Instructions:"
    Write-Host ""
    Write-Host " Web Application:" -ForegroundColor 
    Write-Host "   kubectl port-forward service/nginx-service 30080:80 -n k8s-assignment"
    Write-Host "   Then open: http://localhost:30080"
    Write-Host ""
    Write-Host " Pod Watcher Logs:" -ForegroundColor 
    Write-Host "   kubectl logs -f daemonset/pod-watcher -n k8s-assignment"
    Write-Host ""
    Write-Host " MySQL Access:" -ForegroundColor 
    Write-Host "   kubectl exec -it mysql-0 -n k8s-assignment -- mysql -u root -p"
    Write-Host ""
}

# Main execution
function Main {
    Write-Status "Starting setup process..."
    
    if (-not (Test-Kubectl)) { exit 1 }
    if (-not (Test-Kind)) { exit 1 }
    
    New-KindCluster
    New-Namespace
    Deploy-MySQL
    Deploy-Nginx
    Deploy-NetworkPolicies
    Deploy-PodWatcher
    
    Write-Status "Setup completed successfully!"
    Write-Host ""
    Show-Status
    Write-Host ""
    Show-Access
}

# Run main function
Main
