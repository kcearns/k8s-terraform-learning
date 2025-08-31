#!/bin/bash
set -e

echo "Setting up development environment..."

# Install basic tools
sudo apt-get update
sudo apt-get install -y curl jq wget unzip gnupg lsb-release

# Install Docker CLI (should already be available via feature, but just in case)
if ! command -v docker &> /dev/null; then
  echo "Docker not found, installing Docker CLI..."
  curl -fsSL https://get.docker.com | sh -
fi

# Install Kind
echo "Installing Kind..."
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install Terraform
echo "Installing Terraform..."
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update
sudo apt-get install -y terraform

# Install just
echo "Installing just..."
if ! command -v just &> /dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | sudo bash -s -- --to /usr/local/bin
fi


# Install eksctl
echo "Installing eksctl..."
EKSCTL_VERSION="v0.191.0"  # Use specific version to avoid API calls
set -x
curl -Lo ./eksctl.tar.gz "https://github.com/eksctl-io/eksctl/releases/download/${EKSCTL_VERSION}/eksctl_Linux_amd64.tar.gz" || { echo "Failed to download eksctl"; exit 1; }
tar -xzf eksctl.tar.gz || { echo "Failed to extract eksctl"; exit 1; }
chmod +x eksctl || { echo "Failed to chmod eksctl"; exit 1; }
sudo mv ./eksctl /usr/local/bin/ || { echo "Failed to move eksctl to /usr/local/bin"; exit 1; }
rm eksctl.tar.gz
set +x
ls -l /usr/local/bin/eksctl || echo "eksctl not found in /usr/local/bin after move"
ls -l /usr/local/bin | grep eksctl || echo "eksctl not listed in /usr/local/bin"
if ! command -v eksctl &> /dev/null; then
  echo "eksctl installation failed. Please check the logs above."
  exit 1
fi


# Install AWS CLI (if not already installed)
echo "Installing AWS CLI..."
if ! command -v aws &> /dev/null; then
  set -x
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" || { echo "Failed to download AWS CLI"; exit 1; }
  unzip awscliv2.zip || { echo "Failed to unzip AWS CLI"; exit 1; }
  sudo ./aws/install || { echo "Failed to install AWS CLI"; exit 1; }
  rm -rf aws awscliv2.zip
  set +x
  ls -l /usr/local/bin/aws* || echo "aws not found in /usr/local/bin after install"
  ls -l /usr/local/bin | grep aws || echo "aws not listed in /usr/local/bin"
  if ! command -v aws &> /dev/null; then
    echo "AWS CLI installation failed. Please check the logs above."
    exit 1
  fi
fi

# Install K9s
echo "Installing K9s..."
K9S_VERSION="v0.32.5"  # Use specific version to avoid API calls
curl -Lo ./k9s.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
tar -xzf k9s.tar.gz
chmod +x k9s
sudo mv ./k9s /usr/local/bin/
rm k9s.tar.gz

# Print versions for verification
echo "Installation complete. Verifying versions:"
docker --version || echo "Docker not installed properly"
kind --version || echo "Kind not installed properly"
kubectl version --client || echo "Kubectl not installed properly"
terraform --version || echo "Terraform not installed properly"
just --version || echo "Just not installed properly"
echo "PATH is: $PATH"
ls -l /usr/local/bin | grep -E 'aws|eksctl' || echo "Neither aws nor eksctl found in /usr/local/bin"
which aws || echo "which aws: not found"
which eksctl || echo "which eksctl: not found"
eksctl version || echo "eksctl not installed properly"
aws --version || echo "AWS CLI not installed properly"
k9s version --short || echo "K9s not installed properly"

echo "Setup completed successfully"
