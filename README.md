# Learning Kubernetes + Terraform

This repository provides multiple ways to learn and experiment with Kubernetes clusters:

## Cluster Options

### 1. Local Development - Kind
- **Purpose**: Local testing and development
- **Cost**: Free
- **Setup**: `just kind`
- **Documentation**: See [k8s/README.md](k8s/README.md)

### 2. AWS EKS with eksctl
- **Purpose**: Quick cloud cluster setup with opinionated defaults
- **Cost**: AWS EKS charges apply
- **Setup**: `just eks-create-dev`
- **Documentation**: See [eksctl/README.md](eksctl/README.md)

### 3. AWS EKS with Terraform
- **Purpose**: Infrastructure as code with full control
- **Cost**: AWS EKS charges apply  
- **Setup**: See [terraform/README.md](terraform/README.md)

## Quick Start

### Local Development (Free)
```bash
# Create local cluster
just kind

# Deploy sample app
just nginx

# Debug with netshoot
just netshoot

# Clean up
just teardown
```

### Cloud Development with eksctl (AWS costs apply)
```bash
# Create EKS cluster
just eks-create-dev

# Update kubectl context
just eks-update-kubeconfig-dev

# Deploy sample app
just nginx

# Clean up (important!)
just eks-delete-dev
```

## Commands

### Docker
```bash
docker build -t [image]:[tag] .
docker image ls
docker system prune -a
```

### Kubernetes
```bash
kubectl port-forward pod/[pod name] 3000:80
kubectl get pods
kubectl get nodes
```

### Available just commands
- `just kind` - Create local Kind cluster
- `just eks-create-dev` - Create development EKS cluster
- `just eks-create` - Create production EKS cluster  
- `just nginx` - Deploy sample nginx application
- `just netshoot` - Run debugging container
- `just teardown` - Delete Kind cluster
- `just eks-delete-dev` - Delete development EKS cluster
- `just eks-delete` - Delete production EKS cluster

## Project Structure

```
├── k8s/                    # Kubernetes manifests and Kind config
├── eksctl/                 # eksctl cluster configurations
├── terraform/              # Terraform EKS infrastructure
├── docker/                 # Container configurations
├── .devcontainer/         # Development environment setup
└── justfile               # Command shortcuts
```

## Getting Started

1. **Choose your learning path:**
   - Start with Kind for local development (free)
   - Move to eksctl for simple cloud clusters
   - Use Terraform for infrastructure as code

2. **Set up your environment:**
   - Use the devcontainer for a pre-configured environment
   - Or install tools manually: kubectl, kind, eksctl, terraform

3. **Follow the documentation:**
   - [k8s/README.md](k8s/README.md) for Kind and local development
   - [eksctl/README.md](eksctl/README.md) for eksctl usage
   - [terraform/README.md](terraform/README.md) for Terraform usage
   - [docker/README.md](docker/README.md) for Docker containers
   - [.devcontainer/README.md](.devcontainer/README.md) for development environment setup

## Documentation

- **[CLUSTER-COMPARISON.md](CLUSTER-COMPARISON.md)** - Detailed comparison of Kind, eksctl, and Terraform
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Guidelines for contributing to this project
- **Component Documentation**:
  - [k8s/README.md](k8s/README.md) - Kind cluster and Kubernetes manifests
  - [eksctl/README.md](eksctl/README.md) - EKS cluster with eksctl
  - [terraform/README.md](terraform/README.md) - EKS cluster with Terraform
  - [docker/README.md](docker/README.md) - Docker container configurations
  - [.devcontainer/README.md](.devcontainer/README.md) - Development environment

## Resources

- [Kubernetes](https://kubernetes.io)
- [eksctl](https://eksctl.io/)
- [Terraform](https://www.terraform.io/)
- [Kind](https://kind.sigs.k8s.io/)