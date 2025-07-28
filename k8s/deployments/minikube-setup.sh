#!/bin/bash

echo "🚀 Minikube Setup and Validation Script"
echo "========================================"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
K8S_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$K8S_DIR")"

# Check if minikube is installed
if ! command -v minikube &> /dev/null; then
    echo "❌ Minikube is not installed. Please install minikube first."
    echo "📖 Installation guide: https://minikube.sigs.k8s.io/docs/start/"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    echo "📖 Installation guide: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

echo "✅ Prerequisites check passed!"

# Start Minikube
echo "🔧 Starting Minikube..."
minikube start --memory=4096 --cpus=2 --driver=docker

# Enable addons
echo "🔧 Enabling Minikube addons..."
minikube addons enable ingress
minikube addons enable metrics-server

# Build Docker images in Minikube context
echo "🔧 Building Docker images in Minikube context..."
eval $(minikube docker-env)

echo "📦 Building user-service image..."
docker build -t user-service:latest "$PROJECT_ROOT/Microservices/user-service/"

echo "📦 Building product-service image..."
docker build -t product-service:latest "$PROJECT_ROOT/Microservices/product-service/"

echo "📦 Building order-service image..."
docker build -t order-service:latest "$PROJECT_ROOT/Microservices/order-service/"

echo "📦 Building gateway-service image..."
docker build -t gateway-service:latest "$PROJECT_ROOT/Microservices/gateway-service/"

# Deploy to Kubernetes
echo "🚀 Deploying to Kubernetes..."
"$K8S_DIR/deployments/deploy-all.sh"

# Wait for all pods to be ready
echo "⏳ Waiting for all pods to be ready..."
kubectl wait --for=condition=ready pod -l app=user-service -n microservices --timeout=300s
kubectl wait --for=condition=ready pod -l app=product-service -n microservices --timeout=300s
kubectl wait --for=condition=ready pod -l app=order-service -n microservices --timeout=300s
kubectl wait --for=condition=ready pod -l app=gateway-service -n microservices --timeout=300s

echo "✅ All pods are ready!"

# Show status
echo "📊 Current status:"
kubectl get all -n microservices

echo "🌐 Services:"
kubectl get services -n microservices

echo "🔗 Ingress:"
kubectl get ingress -n microservices

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)
echo "🖥️  Minikube IP: $MINIKUBE_IP"

# Get Gateway Service NodePort
GATEWAY_PORT=$(kubectl get service gateway-service -n microservices -o jsonpath='{.spec.ports[0].nodePort}')
echo "🌐 Gateway Service accessible at: http://$MINIKUBE_IP:$GATEWAY_PORT"

echo ""
echo "🎉 Minikube setup completed successfully!"
echo "========================================" 