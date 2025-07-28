#!/bin/bash

echo "🧪 Microservices Validation Tests"
echo "================================="

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)
echo "🖥️  Minikube IP: $MINIKUBE_IP"

# Get Gateway Service NodePort
GATEWAY_PORT=$(kubectl get service gateway-service -n microservices -o jsonpath='{.spec.ports[0].nodePort}')
GATEWAY_URL="http://$MINIKUBE_IP:$GATEWAY_PORT"

echo "🌐 Gateway URL: $GATEWAY_URL"
echo ""

# Test 1: Gateway Health Check
echo "🔍 Test 1: Gateway Health Check"
echo "--------------------------------"
curl -s "$GATEWAY_URL/health" | jq . || curl -s "$GATEWAY_URL/health"
echo ""

# Test 2: User Service via Gateway
echo "🔍 Test 2: User Service via Gateway"
echo "-----------------------------------"
echo "Fetching users..."
curl -s "$GATEWAY_URL/api/users" | jq . || curl -s "$GATEWAY_URL/api/users"
echo ""

# Test 3: Product Service via Gateway
echo "🔍 Test 3: Product Service via Gateway"
echo "--------------------------------------"
echo "Fetching products..."
curl -s "$GATEWAY_URL/api/products" | jq . || curl -s "$GATEWAY_URL/api/products"
echo ""

# Test 4: Order Service via Gateway
echo "🔍 Test 4: Order Service via Gateway"
echo "------------------------------------"
echo "Fetching orders..."
curl -s "$GATEWAY_URL/api/orders" | jq . || curl -s "$GATEWAY_URL/api/orders"
echo ""

# Test 5: Create Order via Gateway
echo "🔍 Test 5: Create Order via Gateway"
echo "-----------------------------------"
echo "Creating a new order..."
curl -s -X POST "$GATEWAY_URL/api/orders" \
  -H "Content-Type: application/json" \
  -d '{"userId": 1, "productId": 1}' | jq . || curl -s -X POST "$GATEWAY_URL/api/orders" \
  -H "Content-Type: application/json" \
  -d '{"userId": 1, "productId": 1}'
echo ""

# Test 6: Direct Service Access (if NodePort available)
echo "🔍 Test 6: Direct Service Access"
echo "---------------------------------"

# Get NodePorts for direct access
USER_PORT=$(kubectl get service user-service -n microservices -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
PRODUCT_PORT=$(kubectl get service product-service -n microservices -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
ORDER_PORT=$(kubectl get service order-service -n microservices -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)

if [ ! -z "$USER_PORT" ]; then
    echo "Testing User Service directly..."
    curl -s "http://$MINIKUBE_IP:$USER_PORT/health" | jq . || curl -s "http://$MINIKUBE_IP:$USER_PORT/health"
    echo ""
fi

if [ ! -z "$PRODUCT_PORT" ]; then
    echo "Testing Product Service directly..."
    curl -s "http://$MINIKUBE_IP:$PRODUCT_PORT/health" | jq . || curl -s "http://$MINIKUBE_IP:$PRODUCT_PORT/health"
    echo ""
fi

if [ ! -z "$ORDER_PORT" ]; then
    echo "Testing Order Service directly..."
    curl -s "http://$MINIKUBE_IP:$ORDER_PORT/health" | jq . || curl -s "http://$MINIKUBE_IP:$ORDER_PORT/health"
    echo ""
fi

# Test 7: Pod Logs Check
echo "🔍 Test 7: Pod Logs Check"
echo "-------------------------"
echo "Checking recent logs from all pods..."

echo "Gateway Service logs:"
kubectl logs -l app=gateway-service -n microservices --tail=5
echo ""

echo "User Service logs:"
kubectl logs -l app=user-service -n microservices --tail=5
echo ""

echo "Product Service logs:"
kubectl logs -l app=product-service -n microservices --tail=5
echo ""

echo "Order Service logs:"
kubectl logs -l app=order-service -n microservices --tail=5
echo ""

# Test 8: Service Discovery Test
echo "🔍 Test 8: Service Discovery Test"
echo "---------------------------------"
echo "Testing inter-service communication from gateway pod..."

GATEWAY_POD=$(kubectl get pods -l app=gateway-service -n microservices -o jsonpath='{.items[0].metadata.name}')
if [ ! -z "$GATEWAY_POD" ]; then
    echo "Testing connection to user-service from gateway..."
    kubectl exec $GATEWAY_POD -n microservices -- curl -s http://user-service:3001/health
    echo ""
    
    echo "Testing connection to product-service from gateway..."
    kubectl exec $GATEWAY_POD -n microservices -- curl -s http://product-service:3002/health
    echo ""
    
    echo "Testing connection to order-service from gateway..."
    kubectl exec $GATEWAY_POD -n microservices -- curl -s http://order-service:3003/health
    echo ""
fi

# Test 9: Ingress Testing
echo "🔍 Test 9: Ingress Testing"
echo "---------------------------"
echo "Testing Ingress routing rules..."

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)
echo "🖥️  Minikube IP: $MINIKUBE_IP"

# Test Ingress endpoints
echo "Testing Ingress health endpoint..."
curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/health" | jq . || curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/health"
echo ""

echo "Testing Ingress users endpoint..."
curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/api/users" | jq . || curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/api/users"
echo ""

echo "Testing Ingress products endpoint..."
curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/api/products" | jq . || curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/api/products"
echo ""

echo "Testing Ingress orders endpoint..."
curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/api/orders" | jq . || curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/api/orders"
echo ""

echo "Testing Ingress root endpoint..."
curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/" | jq . || curl -s -H "Host: microservices.local" "http://$MINIKUBE_IP/"
echo ""

echo ""
echo "✅ Validation tests completed!"
echo "==============================" 