# Minikube Setup and Validation Guide

## 🎯 Overview
This guide covers the complete setup and validation of microservices on Minikube, including inter-service communication testing.

## 📋 Prerequisites

### Required Tools
- **Minikube**: Local Kubernetes cluster
- **kubectl**: Kubernetes command-line tool
- **Docker**: Container runtime
- **curl**: HTTP client for testing
- **jq**: JSON processor (optional, for pretty output)

### Installation Links
- [Minikube Installation](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl Installation](https://kubernetes.io/docs/tasks/tools/)
- [Docker Installation](https://docs.docker.com/get-docker/)

## 🚀 Quick Start

### 1. One-Click Setup
```bash
cd k8s
chmod +x minikube-setup.sh
./minikube-setup.sh
```

### 2. Manual Setup
```bash
# Start Minikube
minikube start --memory=4096 --cpus=2 --driver=docker

# Enable addons
minikube addons enable ingress
minikube addons enable metrics-server

# Build images in Minikube context
eval $(minikube docker-env)
docker build -t user-service:latest ../Microservices/user-service/
docker build -t product-service:latest ../Microservices/product-service/
docker build -t order-service:latest ../Microservices/order-service/
docker build -t gateway-service:latest ../Microservices/gateway-service/

# Deploy to Kubernetes
./deploy-all.sh
```

## 🧪 Validation Tests

### Run All Tests
```bash
chmod +x validation-tests.sh
./validation-tests.sh
```

### Manual Testing

#### 1. Check Pod Status
```bash
kubectl get pods -n microservices
kubectl get services -n microservices
```

#### 2. Test Gateway Service
```bash
# Get Minikube IP and Gateway Port
MINIKUBE_IP=$(minikube ip)
GATEWAY_PORT=$(kubectl get service gateway-service -n microservices -o jsonpath='{.spec.ports[0].nodePort}')

# Test health endpoint
curl http://$MINIKUBE_IP:$GATEWAY_PORT/health

# Test API endpoints
curl http://$MINIKUBE_IP:$GATEWAY_PORT/api/users
curl http://$MINIKUBE_IP:$GATEWAY_PORT/api/products
curl http://$MINIKUBE_IP:$GATEWAY_PORT/api/orders
```

#### 3. Test Inter-Service Communication
```bash
# Get gateway pod name
GATEWAY_POD=$(kubectl get pods -l app=gateway-service -n microservices -o jsonpath='{.items[0].metadata.name}')

# Test connections from gateway to other services
kubectl exec $GATEWAY_POD -n microservices -- curl -s http://user-service:3001/health
kubectl exec $GATEWAY_POD -n microservices -- curl -s http://product-service:3002/health
kubectl exec $GATEWAY_POD -n microservices -- curl -s http://order-service:3003/health
```

#### 4. Check Logs
```bash
# Check logs for all services
kubectl logs -l app=gateway-service -n microservices
kubectl logs -l app=user-service -n microservices
kubectl logs -l app=product-service -n microservices
kubectl logs -l app=order-service -n microservices
```

## 🌐 Access Points

### Gateway Service (NodePort)
- **URL**: `http://<minikube-ip>:30000`
- **Health**: `http://<minikube-ip>:30000/health`
- **Users API**: `http://<minikube-ip>:30000/api/users`
- **Products API**: `http://<minikube-ip>:30000/api/products`
- **Orders API**: `http://<minikube-ip>:30000/api/orders`

### Ingress Controller
- **Host**: `microservices.local`
- **Health**: `http://<minikube-ip>/health` (with Host header)
- **Users API**: `http://<minikube-ip>/api/users` (with Host header)
- **Products API**: `http://<minikube-ip>/api/products` (with Host header)
- **Orders API**: `http://<minikube-ip>/api/orders` (with Host header)
- **Root**: `http://<minikube-ip>/` (with Host header)

### Testing Ingress
```bash
# Add host entry for testing
echo "$(minikube ip) microservices.local" | sudo tee -a /etc/hosts

# Test Ingress endpoints
curl -H "Host: microservices.local" http://$(minikube ip)/health
curl -H "Host: microservices.local" http://$(minikube ip)/api/users
curl -H "Host: microservices.local" http://$(minikube ip)/api/products
curl -H "Host: microservices.local" http://$(minikube ip)/api/orders
```

### Direct Service Access (if needed)
- **User Service**: `http://<minikube-ip>:<nodeport>/health`
- **Product Service**: `http://<minikube-ip>:<nodeport>/health`
- **Order Service**: `http://<minikube-ip>:<nodeport>/health`

## 🔧 Troubleshooting

### Common Issues

#### 1. Pods Not Starting
```bash
# Check pod events
kubectl describe pod <pod-name> -n microservices

# Check pod logs
kubectl logs <pod-name> -n microservices
```

#### 2. Service Not Accessible
```bash
# Check service endpoints
kubectl get endpoints -n microservices

# Check service configuration
kubectl describe service <service-name> -n microservices
```

#### 3. Image Pull Issues
```bash
# Ensure images are built in Minikube context
eval $(minikube docker-env)
docker images

# Rebuild if needed
docker build -t <service-name>:latest ../Microservices/<service-name>/
```

#### 4. Network Issues
```bash
# Check network policies
kubectl get networkpolicies -n microservices

# Test connectivity between pods
kubectl exec <source-pod> -n microservices -- curl <target-service>:<port>
```

## 📊 Monitoring

### Resource Usage
```bash
# Check resource usage
kubectl top pods -n microservices
kubectl top nodes

# Check events
kubectl get events -n microservices --sort-by='.lastTimestamp'
```

### Service Discovery
```bash
# Test DNS resolution
kubectl exec <pod-name> -n microservices -- nslookup user-service
kubectl exec <pod-name> -n microservices -- nslookup product-service
kubectl exec <pod-name> -n microservices -- nslookup order-service
```

## 🧹 Cleanup

### Complete Cleanup
```bash
# Stop Minikube
minikube stop

# Delete Minikube cluster
minikube delete

# Or use cleanup script
./cleanup.sh
```

## ✅ Validation Checklist

- [ ] Minikube started successfully
- [ ] All pods are in Running state
- [ ] All services are accessible
- [ ] Gateway service responds to health checks
- [ ] User service data retrieved via gateway
- [ ] Product service data retrieved via gateway
- [ ] Order service data retrieved via gateway
- [ ] Order creation works via gateway
- [ ] Inter-service communication verified
- [ ] Service discovery working
- [ ] Logs show successful requests
- [ ] No error messages in pod logs

## 🎉 Success Criteria

The setup is successful when:
1. All 8 pods are running (2 replicas × 4 services)
2. Gateway service is accessible via NodePort
3. All API endpoints return valid JSON responses
4. Inter-service communication works without errors
5. Service discovery resolves all service names
6. Health checks pass for all services 