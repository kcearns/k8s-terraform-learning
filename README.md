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

### Next.js on EKS (AWS costs apply)
```bash
# Create Next.js-optimized EKS cluster
just nextjs-eks-create

# Update kubectl context
just nextjs-eks-kubeconfig

# Build and deploy (see NEXTJS-DEPLOYMENT-GUIDE.md for image registry setup)
just nextjs-build
# Push to registry (ECR or Docker Hub)
just nextjs-deploy

# Check status
just nextjs-status

# Clean up (important!)
just nextjs-delete
just nextjs-eks-delete
```

For complete Next.js deployment instructions, see [NEXTJS-DEPLOYMENT-GUIDE.md](NEXTJS-DEPLOYMENT-GUIDE.md).

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

**Cluster Management:**
- `just kind` - Create local Kind cluster
- `just eks-create-dev` - Create development EKS cluster
- `just eks-create` - Create production EKS cluster
- `just nextjs-eks-create` - Create Next.js-optimized EKS cluster
- `just teardown` - Delete Kind cluster
- `just eks-delete-dev` - Delete development EKS cluster
- `just eks-delete` - Delete production EKS cluster
- `just nextjs-eks-delete` - Delete Next.js EKS cluster

**Application Deployment:**
- `just nginx` - Deploy sample nginx application
- `just nextjs-build` - Build Next.js Docker image
- `just nextjs-deploy` - Deploy Next.js application
- `just nextjs-status` - Get Next.js application status
- `just nextjs-logs` - View Next.js application logs
- `just nextjs-delete` - Delete Next.js application

**Utilities:**
- `just netshoot` - Run debugging container

## Project Structure

```
├── k8s/                    # Kubernetes manifests and Kind config
│   └── manifests/
│       ├── nginx.yaml      # Sample nginx deployment
│       └── nextjs.yaml     # Next.js deployment configuration
├── eksctl/                 # eksctl cluster configurations
│   ├── cluster.yaml        # Production cluster
│   ├── dev-cluster.yaml    # Development cluster
│   └── nextjs-cluster.yaml # Next.js-optimized cluster
├── terraform/              # Terraform EKS infrastructure
├── docker/                 # Container configurations
│   ├── Dockerfile          # nginx Dockerfile
│   └── Dockerfile.nextjs   # Next.js production Dockerfile
├── nextjs-app/            # Sample Next.js application
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

3. **Configure AWS credentials** (for EKS clusters):
   - See [AWS-SETUP.md](AWS-SETUP.md) for detailed instructions
   - Use GitHub Codespaces secrets for automatic configuration

4. **Follow the documentation:**
   - [k8s/README.md](k8s/README.md) for Kind and local development
   - [eksctl/README.md](eksctl/README.md) for eksctl usage
   - [terraform/README.md](terraform/README.md) for Terraform usage
   - [docker/README.md](docker/README.md) for Docker containers
   - [.devcontainer/README.md](.devcontainer/README.md) for development environment setup

## Documentation

- **[AWS-SETUP.md](AWS-SETUP.md)** - 🔐 How to configure AWS credentials for Codespaces and EKS
- **[CLUSTER-COMPARISON.md](CLUSTER-COMPARISON.md)** - Detailed comparison of Kind, eksctl, and Terraform
- **[NEXTJS-DEPLOYMENT-GUIDE.md](NEXTJS-DEPLOYMENT-GUIDE.md)** - Complete guide for deploying Next.js on AWS EKS
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Guidelines for contributing to this project
- **Component Documentation**:
  - [k8s/README.md](k8s/README.md) - Kind cluster and Kubernetes manifests
  - [eksctl/README.md](eksctl/README.md) - EKS cluster with eksctl
  - [terraform/README.md](terraform/README.md) - EKS cluster with Terraform
  - [docker/README.md](docker/README.md) - Docker container configurations
  - [nextjs-app/README.md](nextjs-app/README.md) - Next.js application setup
  - [.devcontainer/README.md](.devcontainer/README.md) - Development environment

## Resources

- [Kubernetes](https://kubernetes.io)
- [eksctl](https://eksctl.io/)
- [Terraform](https://www.terraform.io/)
- [Kind](https://kind.sigs.k8s.io/)