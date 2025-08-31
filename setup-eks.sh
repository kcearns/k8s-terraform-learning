#!/bin/bash
set -e

echo "🚀 EKS cluster setup with eksctl"
echo "================================="

# Check if eksctl is installed
if ! command -v eksctl &> /dev/null; then
    echo "❌ eksctl is not installed. Please run the devcontainer setup or install eksctl manually."
    echo "   Installation: https://eksctl.io/installation/"
    exit 1
fi

# Check if AWS CLI is configured
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install it first."
    exit 1
fi

if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS CLI is not configured. Please run 'aws configure' first."
    echo "   You'll need:"
    echo "   - AWS Access Key ID"
    echo "   - AWS Secret Access Key"
    echo "   - Default region (e.g., us-east-1)"
    exit 1
fi

echo "✅ Prerequisites check passed"
echo ""

echo "📋 Available cluster configurations:"
echo "1. dev-cluster.yaml    - Minimal development cluster (t3.micro, cost-optimized)"
echo "2. cluster.yaml        - Full production cluster (more features, higher cost)"
echo ""

read -p "Choose configuration (1 or 2): " choice

case $choice in
    1)
        CONFIG_FILE="eksctl/dev-cluster.yaml"
        CLUSTER_NAME="dev-eksctl-cluster"
        echo "🔧 Creating development cluster..."
        ;;
    2)
        CONFIG_FILE="eksctl/cluster.yaml"
        CLUSTER_NAME="my-eksctl-cluster"
        echo "🔧 Creating production cluster..."
        ;;
    *)
        echo "❌ Invalid choice. Exiting."
        exit 1
        ;;
esac

echo "📁 Using configuration: $CONFIG_FILE"
echo "🏷️  Cluster name: $CLUSTER_NAME"
echo ""

read -p "🚨 This will create AWS resources that incur costs. Continue? (y/N): " confirm
if [[ $confirm != [yY] ]]; then
    echo "❌ Cancelled by user"
    exit 1
fi

echo "⏳ Creating EKS cluster (this will take 15-20 minutes)..."
eksctl create cluster -f "$CONFIG_FILE"

echo ""
echo "✅ Cluster created successfully!"
echo ""
echo "🔧 Updating kubectl configuration..."
eksctl utils write-kubeconfig --cluster="$CLUSTER_NAME" --region=us-east-1

echo ""
echo "🧪 Testing cluster connection..."
kubectl get nodes

echo ""
echo "🎉 Setup complete! Your EKS cluster is ready."
echo ""
echo "Next steps:"
echo "  • Deploy sample app: just nginx"
echo "  • Open cluster dashboard: k9s"
echo "  • Run debug container: just netshoot"
echo ""
echo "⚠️  Important: Don't forget to delete the cluster when done to avoid charges:"
if [[ $choice == "1" ]]; then
    echo "  just eks-delete-dev"
else
    echo "  just eks-delete"
fi