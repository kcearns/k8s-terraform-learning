#!/bin/bash
set -e

# Check if Kind is installed
if ! command -v kind &> /dev/null; then
    echo "Kind is not installed. Installing it now..."
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
fi

# Check if a Kind cluster is already running
if kind get clusters | grep -q "platform-sandbox"; then
    echo "Platform sandbox cluster is already running."
else
    echo "Creating Kind cluster with config from k8s/kind.yaml..."
    kind create cluster --config k8s/kind.yaml
fi

# Wait for cluster to be ready
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=60s

echo "Local Kind cluster is ready! You can now run:"
echo "just nginx - to deploy the nginx example"
echo "just netshoot - to run a debugging container"
echo "just teardown - to delete the cluster when you're done"
echo ""
echo "For cloud clusters with AWS EKS:"
echo "./setup-eks.sh - interactive EKS cluster setup"
echo "just eks-create-dev - create development EKS cluster"
echo "just eks-delete-dev - delete development EKS cluster"
