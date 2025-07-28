#!/bin/bash

echo "🧹 Cleaning up Microservices from Kubernetes..."

# Delete all resources in the namespace
echo "🗑️  Deleting all resources in microservices namespace..."
kubectl delete namespace microservices

# Wait for namespace deletion
echo "⏳ Waiting for namespace deletion..."
kubectl wait --for=delete namespace/microservices --timeout=60s

echo "✅ Cleanup completed successfully!"
echo "📊 Checking if namespace still exists..."
kubectl get namespace microservices 2>/dev/null || echo "Namespace microservices has been deleted." 