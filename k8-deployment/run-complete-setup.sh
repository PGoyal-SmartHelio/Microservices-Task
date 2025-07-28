#!/bin/bash

echo "🚀 Complete Microservices Kubernetes Setup Script"
echo "================================================="

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOYMENTS_DIR="$SCRIPT_DIR/deployments"
INGRESS_DIR="$SCRIPT_DIR/ingress"

# Function to handle errors
handle_error() {
    echo "❌ Error occurred at line $1"
    echo "🔍 Check the logs above for more details"
    exit 1
}

# Set error handling
trap 'handle_error $LINENO' ERR

# Step 1: Cleanup any existing resources
echo "🧹 Step 1: Cleaning up existing resources..."
"$DEPLOYMENTS_DIR/cleanup.sh"

# Wait a bit for cleanup to complete
sleep 5

# Step 2: Setup Minikube and deploy services
echo "🔧 Step 2: Setting up Minikube and deploying services..."
"$DEPLOYMENTS_DIR/minikube-setup.sh"

# Step 3: Run validation tests
echo "🧪 Step 3: Running validation tests..."
"$DEPLOYMENTS_DIR/validation-tests.sh"

# Step 4: Test Ingress routing
echo "🔗 Step 4: Testing Ingress routing..."
"$INGRESS_DIR/test-ingress.sh"

# Final status check
echo "📊 Final Status Check:"
echo "======================"
kubectl get all -n microservices
echo ""
kubectl get services -n microservices
echo ""
kubectl get ingress -n microservices

# Get access information
MINIKUBE_IP=$(minikube ip)
GATEWAY_PORT=$(kubectl get service gateway-service -n microservices -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "30000")

echo ""
echo "🎉 Complete setup finished successfully!"
echo "========================================"
echo "🖥️  Minikube IP: $MINIKUBE_IP"
echo "🌐 Gateway Service: http://$MINIKUBE_IP:$GATEWAY_PORT"
echo "🔗 Ingress (with Host header): http://$MINIKUBE_IP (use Host: microservices.local)"
echo ""
echo "📝 Quick Test Commands:"
echo "curl -H 'Host: microservices.local' http://$MINIKUBE_IP/health"
echo "curl -H 'Host: microservices.local' http://$MINIKUBE_IP/api/users"
echo "curl -H 'Host: microservices.local' http://$MINIKUBE_IP/api/products"
echo "curl -H 'Host: microservices.local' http://$MINIKUBE_IP/api/orders" 