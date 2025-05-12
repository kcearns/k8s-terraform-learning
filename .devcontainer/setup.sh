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

# Install K9s
echo "Installing K9s..."
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.tag_name')
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
k9s version --short || echo "K9s not installed properly"

echo "Setup completed successfully"
