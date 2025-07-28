#!/bin/bash

echo "🚀 Deploying Microservices to Kubernetes..."

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
K8S_DIR="$(dirname "$SCRIPT_DIR")"

# Create namespace
echo "📦 Creating namespace..."
kubectl apply -f "$K8S_DIR/configs/namespace.yaml"

# Apply ConfigMap
echo "⚙️  Applying ConfigMap..."
kubectl apply -f "$K8S_DIR/configs/configmap.yaml"

# Deploy services
echo "🔧 Deploying User Service..."
kubectl apply -f "$K8S_DIR/services/user-service-deployment.yaml"

echo "🔧 Deploying Product Service..."
kubectl apply -f "$K8S_DIR/services/product-service-deployment.yaml"

echo "🔧 Deploying Order Service..."
kubectl apply -f "$K8S_DIR/services/order-service-deployment.yaml"

echo "🔧 Deploying Gateway Service..."
kubectl apply -f "$K8S_DIR/services/gateway-service-deployment.yaml"

echo "🔧 Deploying Services..."
kubectl apply -f "$K8S_DIR/services/services.yaml"

echo "🔧 Deploying Ingress..."
kubectl apply -f "$K8S_DIR/ingress/ingress.yaml"

echo "🔧 Deploying Alternative Ingress (Direct Routing)..."
kubectl apply -f "$K8S_DIR/ingress/ingress-direct.yaml"

echo "🔧 Deploying Network Policies..."
kubectl apply -f "$K8S_DIR/configs/network-policy.yaml"

# Wait for deployments to be ready
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/user-service -n microservices
kubectl wait --for=condition=available --timeout=300s deployment/product-service -n microservices
kubectl wait --for=condition=available --timeout=300s deployment/order-service -n microservices
kubectl wait --for=condition=available --timeout=300s deployment/gateway-service -n microservices

echo "✅ All services deployed successfully!"
echo "📊 Checking service status..."
kubectl get pods -n microservices
kubectl get services -n microservices

echo "🌐 Gateway Service LoadBalancer IP:"
kubectl get service gateway-service -n microservices -o wide 