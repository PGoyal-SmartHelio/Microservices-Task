#!/bin/bash

echo "🔗 Ingress Routing Test Script"
echo "=============================="

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)
echo "🖥️  Minikube IP: $MINIKUBE_IP"

# Check if ingress controller is running
echo "🔍 Checking Ingress Controller status..."
kubectl get pods -n ingress-nginx
echo ""

# Check Ingress resources
echo "🔍 Checking Ingress resources..."
kubectl get ingress -n microservices
echo ""

# Test Ingress routing rules
echo "🧪 Testing Ingress Routing Rules"
echo "================================"

# Test 1: Root path -> Gateway Service
echo "🔍 Test 1: Root path (/) -> Gateway Service"
echo "---------------------------------------------"
curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/" | jq . || curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/"
echo ""

# Test 2: /api/users -> User Service (via Gateway)
echo "🔍 Test 2: /api/users -> User Service (via Gateway)"
echo "---------------------------------------------------"
curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/api/users" | jq . || curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/api/users"
echo ""

# Test 3: /api/products -> Product Service (via Gateway)
echo "🔍 Test 3: /api/products -> Product Service (via Gateway)"
echo "--------------------------------------------------------"
curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/api/products" | jq . || curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/api/products"
echo ""

# Test 4: /api/orders -> Order Service (via Gateway)
echo "🔍 Test 4: /api/orders -> Order Service (via Gateway)"
echo "-----------------------------------------------------"
curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/api/orders" | jq . || curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/api/orders"
echo ""

# Test 5: /health -> Gateway Service Health
echo "🔍 Test 5: /health -> Gateway Service Health"
echo "--------------------------------------------"
curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/health" | jq . || curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/health"
echo ""

# Test 6: Create Order via Ingress
echo "🔍 Test 6: Create Order via Ingress"
echo "-----------------------------------"
curl -s -X POST -H "Host: microservices.local" -H "Content-Type: application/json" \
  -d '{"userId": 1, "productId": 1}' \
  "http://$MINIKUBE_IP/api/orders" | jq . || curl -s -X POST -H "Host: microservices.local" -H "Content-Type: application/json" \
  -d '{"userId": 1, "productId": 1}' \
  "http://$MINIKUBE_IP/api/orders"
echo ""

# Test 7: Test with different Host header (should fail)
echo "🔍 Test 7: Test with wrong Host header (should fail)"
echo "----------------------------------------------------"
curl -s -H "Host: wrong-host.local" "http://$MINIKUBE_IP/api/users" | jq . || curl -s -H "Host: wrong-host.local" "http://$MINIKUBE_IP/api/users"
echo ""

# Test 8: Test Ingress logs
echo "🔍 Test 8: Ingress Controller Logs"
echo "----------------------------------"
echo "Recent Ingress controller logs:"
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --tail=10
echo ""

echo "✅ Ingress routing tests completed!"
echo "===================================" 