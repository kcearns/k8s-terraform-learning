#!/bin/bash
set -e

echo "Setting up development environment..."

# Install basic tools
apt-get update
apt-get install -y curl jq wget unzip gnupg lsb-release

# Install Docker CLI (should already be available via feature, but just in case)
if ! command -v docker &> /dev/null; then
  echo "Docker not found, installing Docker CLI..."
  curl -fsSL https://get.docker.com | sh -
fi

# Install Kind
echo "Installing Kind..."
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install Terraform
echo "Installing Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt-get update
apt-get install -y terraform

# Install just
echo "Installing just..."
if ! command -v just &> /dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin
fi


# Install eksctl
echo "Installing eksctl..."
if ! command -v eksctl &> /dev/null; then
  EKSCTL_VERSION="v0.191.0"  # Use specific version to avoid API calls
  TMPDIR=$(mktemp -d)
  cd "$TMPDIR"
  echo "Working in temporary directory: $TMPDIR"
  curl -Lo eksctl.tar.gz "https://github.com/eksctl-io/eksctl/releases/download/${EKSCTL_VERSION}/eksctl_Linux_amd64.tar.gz"
  tar -xzf eksctl.tar.gz
  chmod +x eksctl
  mv eksctl /usr/local/bin/
  cd -
  rm -rf "$TMPDIR"
  if ! command -v eksctl &> /dev/null; then
    echo "ERROR: eksctl installation failed"
    exit 1
  fi
  echo "eksctl installed successfully"
else
  echo "eksctl already installed"
fi


# Install AWS CLI (if not already installed)
echo "Installing AWS CLI..."
if ! command -v aws &> /dev/null; then
  TMPDIR=$(mktemp -d)
  cd "$TMPDIR"
  echo "Working in temporary directory: $TMPDIR"
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip -q awscliv2.zip
  ./aws/install
  cd -
  rm -rf "$TMPDIR"
  if ! command -v aws &> /dev/null; then
    echo "ERROR: AWS CLI installation failed"
    exit 1
  fi
  echo "AWS CLI installed successfully"
else
  echo "AWS CLI already installed"
fi

# Install K9s
echo "Installing K9s..."
if ! command -v k9s &> /dev/null; then
  K9S_VERSION="v0.32.5"  # Use specific version to avoid API calls
  TMPDIR=$(mktemp -d)
  cd "$TMPDIR"
  echo "Working in temporary directory: $TMPDIR"
  curl -Lo k9s.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
  tar -xzf k9s.tar.gz
  chmod +x k9s
  mv k9s /usr/local/bin/
  cd -
  rm -rf "$TMPDIR"
  if ! command -v k9s &> /dev/null; then
    echo "ERROR: K9s installation failed"
    exit 1
  fi
  echo "K9s installed successfully"
else
  echo "K9s already installed"
fi

# Print versions for verification
echo ""
echo "============================================"
echo "Installation complete. Verifying versions:"
echo "============================================"
docker --version || echo "❌ Docker not installed properly"
kind --version || echo "❌ Kind not installed properly"
kubectl version --client || echo "❌ Kubectl not installed properly"
terraform --version || echo "❌ Terraform not installed properly"
just --version || echo "❌ Just not installed properly"
eksctl version || echo "❌ eksctl not installed properly"
aws --version || echo "❌ AWS CLI not installed properly"
k9s version --short || echo "❌ K9s not installed properly"
echo "============================================"
echo "✅ Setup completed successfully"
echo "============================================"

# Configure AWS credentials if environment variables are available
echo ""
if [ -f ".devcontainer/configure-aws.sh" ]; then
  bash .devcontainer/configure-aws.sh
fi
