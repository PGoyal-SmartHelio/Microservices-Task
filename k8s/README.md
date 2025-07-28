# Kubernetes Microservices Setup

Yeh directory mein aapke microservices ko Kubernetes mein deploy karne ke liye saare files hain.

## Quick Start

Pura setup run karne ke liye ek hi command:

```bash
./k8s/run-complete-setup.sh
```

Yeh script automatically:
1. Existing resources ko cleanup karega
2. Minikube setup karega
3. Saare services deploy karega
4. Validation tests run karega
5. Ingress routing test karega

## Individual Scripts

### 1. Complete Setup
```bash
./k8s/run-complete-setup.sh
```
- Pura end-to-end setup run karta hai

### 2. Cleanup
```bash
./k8s/deployments/cleanup.sh
```
- Existing microservices namespace ko delete karta hai

### 3. Minikube Setup
```bash
./k8s/deployments/minikube-setup.sh
```
- Minikube start karta hai
- Docker images build karta hai
- Services deploy karta hai

### 4. Deploy All Services
```bash
./k8s/deployments/deploy-all.sh
```
- Saare Kubernetes resources deploy karta hai

### 5. Validation Tests
```bash
./k8s/deployments/validation-tests.sh
```
- Saare services ko test karta hai
- Health checks run karta hai
- Inter-service communication test karta hai

### 6. Ingress Tests
```bash
./k8s/ingress/test-ingress.sh
```
- Ingress routing rules test karta hai
- Host-based routing verify karta hai

## Directory Structure

```
k8s/
├── configs/                    # Configuration files
│   ├── namespace.yaml         # Microservices namespace
│   ├── configmap.yaml         # Application configs
│   └── network-policy.yaml    # Network policies
├── deployments/               # Deployment scripts
│   ├── cleanup.sh            # Cleanup script
│   ├── deploy-all.sh         # Deploy all services
│   ├── minikube-setup.sh     # Minikube setup
│   └── validation-tests.sh   # Validation tests
├── ingress/                  # Ingress configuration
│   ├── ingress.yaml          # Main ingress rules
│   ├── ingress-direct.yaml   # Direct routing ingress
│   └── test-ingress.sh       # Ingress tests
├── services/                 # Service deployments
│   ├── gateway-service-deployment.yaml
│   ├── order-service-deployment.yaml
│   ├── product-service-deployment.yaml
│   ├── services.yaml         # Service definitions
│   └── user-service-deployment.yaml
└── run-complete-setup.sh     # Complete setup script
```

## Access URLs

Setup ke baad aap yeh URLs use kar sakte hain:

### Gateway Service (Direct)
```bash
# Get Minikube IP
MINIKUBE_IP=$(minikube ip)
GATEWAY_PORT=$(kubectl get service gateway-service -n microservices -o jsonpath='{.spec.ports[0].nodePort}')

# Access gateway
curl http://$MINIKUBE_IP:$GATEWAY_PORT/health
```

### Ingress (with Host Header)
```bash
# Get Minikube IP
MINIKUBE_IP=$(minikube ip)

# Access via ingress
curl -H "Host: microservices.local" http://$MINIKUBE_IP/health
curl -H "Host: microservices.local" http://$MINIKUBE_IP/api/users
curl -H "Host: microservices.local" http://$MINIKUBE_IP/api/products
curl -H "Host: microservices.local" http://$MINIKUBE_IP/api/orders
```

## Troubleshooting

### Common Issues

1. **Minikube not starting**
   ```bash
   minikube delete
   minikube start --memory=4096 --cpus=2 --driver=docker
   ```

2. **Images not building**
   ```bash
   eval $(minikube docker-env)
   docker build -t user-service:latest ../Microservices/user-service/
   ```

3. **Services not accessible**
   ```bash
   kubectl get pods -n microservices
   kubectl logs <pod-name> -n microservices
   ```

4. **Ingress not working**
   ```bash
   minikube addons enable ingress
   kubectl get pods -n ingress-nginx
   ```

### Useful Commands

```bash
# Check all resources
kubectl get all -n microservices

# Check services
kubectl get services -n microservices

# Check ingress
kubectl get ingress -n microservices

# Check pod logs
kubectl logs -l app=gateway-service -n microservices

# Port forward for debugging
kubectl port-forward service/gateway-service 8080:80 -n microservices
```

## Prerequisites

- Minikube installed
- kubectl installed
- Docker installed
- jq (optional, for JSON formatting)

## Notes

- Saare scripts mein relative paths fix kiye gaye hain
- Error handling add kiya gaya hai
- Single command se pura setup run ho jata hai
- Validation tests automatically run hote hain 