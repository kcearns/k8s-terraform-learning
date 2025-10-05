#!/bin/bash
# configure-aws.sh - Configure AWS credentials from environment variables or secrets
# This script sets up AWS CLI credentials from GitHub Codespaces secrets or environment variables
set -e

echo "🔐 Configuring AWS credentials..."

# Create AWS config directory if it doesn't exist
mkdir -p ~/.aws

# Check if AWS credentials are available via environment variables
if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "✅ Found AWS credentials in environment variables"
    
    # Set default region if not provided
    AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
    
    # Create AWS credentials file
    cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
EOF
    
    # Create AWS config file
    cat > ~/.aws/config <<EOF
[default]
region = $AWS_DEFAULT_REGION
output = json
EOF
    
    # Set proper permissions
    chmod 600 ~/.aws/credentials
    chmod 600 ~/.aws/config
    
    echo "✅ AWS credentials configured successfully"
    echo "   Region: $AWS_DEFAULT_REGION"
    
    # Verify credentials work
    if aws sts get-caller-identity &> /dev/null; then
        echo "✅ AWS credentials verified successfully"
        aws sts get-caller-identity
    else
        echo "⚠️  AWS credentials configured but unable to verify (check permissions)"
    fi
else
    echo "ℹ️  No AWS credentials found in environment variables"
    echo ""
    echo "To configure AWS credentials in GitHub Codespaces:"
    echo "1. Go to your repository Settings → Secrets and variables → Codespaces"
    echo "2. Add the following secrets:"
    echo "   - AWS_ACCESS_KEY_ID: Your AWS Access Key ID"
    echo "   - AWS_SECRET_ACCESS_KEY: Your AWS Secret Access Key"
    echo "   - AWS_DEFAULT_REGION: Your preferred region (e.g., us-east-1) [optional]"
    echo ""
    echo "Alternatively, run 'aws configure' manually:"
    echo "   aws configure"
    echo ""
fi
