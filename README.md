# Kubernetes Deployment for Microservices

## Overview
This directory contains Kubernetes manifests for deploying the microservices application to a Kubernetes cluster.

## 📚 Documentation
- **[Minikube Setup Guide](MINIKUBE_GUIDE.md)** - Complete Minikube setup and validation guide
- **[Deployment Summary](DEPLOYMENT_SUMMARY.md)** - Detailed resource list and requirements fulfillment

## Services Included
- **User Service** - Manages user data
- **Product Service** - Manages product catalog
- **Order Service** - Manages order processing
- **Gateway Service** - API Gateway that routes requests to other services

## Prerequisites
- Kubernetes cluster (local or cloud)
- kubectl CLI tool
- Docker images built for all services

## 🚀 Quick Start Options

### Option 1: Complete Setup (Recommended)
```bash
./k8s/run-complete-setup.sh
```
*Runs cleanup, Minikube setup, deployment, and validation tests automatically*

### Option 2: Manual Setup
Follow the step-by-step guide in [Minikube Setup Guide](MINIKUBE_GUIDE.md)

### Option 3: Docker Compose (Alternative)
```bash
docker-compose up -d
```
*For local development without Kubernetes*

## 📋 Manual Setup (Alternative)

### 1. Build Docker Images
First, build the Docker images for all services:
```bash
# From the root directory
docker build -t user-service:latest Microservices/user-service/
docker build -t product-service:latest Microservices/product-service/
docker build -t order-service:latest Microservices/order-service/
docker build -t gateway-service:latest Microservices/gateway-service/
```

### 2. Deploy to Kubernetes
Run the deployment script:
```bash
cd k8s
chmod +x deploy-all.sh
./deploy-all.sh
```

Or deploy manually:
```bash
kubectl apply -f k8s/configs/namespace.yaml
kubectl apply -f k8s/configs/configmap.yaml
kubectl apply -f k8s/services/user-service-deployment.yaml
kubectl apply -f k8s/services/product-service-deployment.yaml
kubectl apply -f k8s/services/order-service-deployment.yaml
kubectl apply -f k8s/services/gateway-service-deployment.yaml
kubectl apply -f k8s/services/services.yaml
kubectl apply -f k8s/ingress/ingress.yaml
kubectl apply -f k8s/configs/network-policy.yaml
```

## Configuration Details

### Resource Limits
- **User/Product/Order Services**: 128Mi-256Mi memory, 100m-200m CPU
- **Gateway Service**: 256Mi-512Mi memory, 200m-500m CPU

### Health Checks
- **Liveness Probe**: Checks `/health` endpoint every 10 seconds
- **Readiness Probe**: Checks `/health` endpoint every 5 seconds

### Environment Variables
All services use environment variables for configuration:
- Service ports
- Service hostnames for inter-service communication

## Service Architecture
```
External Traffic
    ↓
Ingress Controller
    ↓
Gateway Service (LoadBalancer)
    ↓
User Service (ClusterIP)    Product Service (ClusterIP)    Order Service (ClusterIP)
```

## Service Configuration

### Service Types
- **Gateway Service**: LoadBalancer (external access)
- **Backend Services**: ClusterIP (internal communication only)

### Port Configuration
- **Gateway Service**: Port 80/443 (external), 3000 (internal)
- **User Service**: Port 3001
- **Product Service**: Port 3002  
- **Order Service**: Port 3003

### Cluster-Level Service Discovery
All services use Kubernetes DNS for service discovery:
- `user-service.microservices.svc.cluster.local:3001`
- `product-service.microservices.svc.cluster.local:3002`
- `order-service.microservices.svc.cluster.local:3003`

## Monitoring
Check service status:
```bash
kubectl get pods -n microservices
kubectl get services -n microservices
kubectl logs -f deployment/user-service -n microservices
```

## Cleanup
To remove all deployments:
```bash
kubectl delete namespace microservices
```

## Troubleshooting
1. Check pod logs: `kubectl logs <pod-name> -n microservices`
2. Check service endpoints: `kubectl get endpoints -n microservices`
3. Check events: `kubectl get events -n microservices --sort-by='.lastTimestamp'`

## 📖 Additional Resources

### Detailed Guides
- **[Minikube Setup Guide](MINIKUBE_GUIDE.md)** - Complete setup and validation guide
- **[Deployment Summary](DEPLOYMENT_SUMMARY.md)** - Resource details and requirements fulfillment
- **[K8s Directory README](k8s/README.md)** - Kubernetes-specific documentation

### Quick Commands
```bash
# Check status
kubectl get all -n microservices

# View logs
kubectl logs -l app=gateway-service -n microservices

# Port forward for debugging
kubectl port-forward service/gateway-service 8080:80 -n microservices

# Cleanup everything
kubectl delete namespace microservices
```

### Validation Tests
```bash
# Run all validation tests
./k8s/deployments/validation-tests.sh

# Test Ingress routing
./k8s/ingress/test-ingress.sh
``` 