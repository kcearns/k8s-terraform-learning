# EKS with eksctl Configuration

This directory contains configuration files for creating Amazon EKS clusters using [eksctl](https://eksctl.io/), a simple CLI tool for creating and managing clusters on Amazon EKS.

## Prerequisites

- [eksctl](https://eksctl.io/installation/) (installed via devcontainer setup)
- AWS CLI configured with appropriate credentials - **See [AWS-SETUP.md](../AWS-SETUP.md) for setup instructions**
- kubectl (to interact with the cluster after creation)

## Configuration Files

- `cluster.yaml`: Full-featured production-ready cluster configuration
- `dev-cluster.yaml`: Minimal development cluster configuration (cost-optimized)
- `nextjs-cluster.yaml`: Production cluster optimized for Next.js applications

## Quick Start

### 1. Create a Development Cluster (Recommended for learning)

```bash
just eks-create-dev
```

This creates a minimal cluster with:
- 1 t3.micro node (expandable to 2)
- Essential add-ons only
- Minimal logging for cost optimization

### 2. Update kubectl context

```bash
just eks-update-kubeconfig-dev
```

### 3. Verify the cluster

```bash
kubectl get nodes
```

### 4. Deploy sample application

```bash
just nginx
```

### 5. Clean up when done

```bash
just eks-delete-dev
```

## Production Cluster

For a more full-featured cluster with additional add-ons and policies:

```bash
# Create production cluster
just eks-create

# Update kubeconfig
just eks-update-kubeconfig

# Clean up
just eks-delete
```

## Available Commands

| Command | Description |
|---------|-------------|
| `just eks-create` | Create production cluster |
| `just eks-create-dev` | Create development cluster |
| `just nextjs-eks-create` | Create Next.js-optimized cluster |
| `just eks-delete` | Delete production cluster |
| `just eks-delete-dev` | Delete development cluster |
| `just nextjs-eks-delete` | Delete Next.js cluster |
| `just eks-update-kubeconfig` | Update kubectl context for production cluster |
| `just eks-update-kubeconfig-dev` | Update kubectl context for dev cluster |
| `just nextjs-eks-kubeconfig` | Update kubectl context for Next.js cluster |
| `just eks-nodes` | List node groups for production cluster |
| `just eks-nodes-dev` | List node groups for dev cluster |

## Customization

You can customize the cluster configuration by editing the YAML files:

- **cluster.yaml**: Full production configuration with all add-ons
- **dev-cluster.yaml**: Minimal development configuration

### Common customizations:

```yaml
# Change cluster name
metadata:
  name: my-custom-cluster

# Change instance type
managedNodeGroups:
  - name: ng-1
    instanceType: t3.small  # or t3.medium, etc.

# Adjust node scaling
    minSize: 2
    maxSize: 5
    desiredCapacity: 3
```

## Cost Optimization

The development cluster (`dev-cluster.yaml`) is optimized for learning and development:

- Uses t3.micro instances (eligible for free tier)
- Minimal node count
- Essential add-ons only
- Reduced logging retention

**Important**: Remember to delete clusters when not in use to avoid AWS charges:
```bash
just eks-delete-dev
```

## Comparison with Terraform

This repository also includes Terraform configurations for EKS. Here's when to use each:

**Use eksctl when:**
- You want to get started quickly
- You prefer declarative YAML configuration
- You need opinionated defaults that follow AWS best practices
- You're learning EKS basics

**Use Terraform when:**
- You need to integrate with existing Terraform infrastructure
- You require fine-grained control over all resources
- You're managing complex multi-service infrastructure
- You need to customize VPC, subnets, and other infrastructure components

## Troubleshooting

### Authentication Issues
Ensure AWS credentials are configured. See [AWS-SETUP.md](../AWS-SETUP.md) for detailed instructions.

Quick check:
```bash
# Verify credentials are configured
aws sts get-caller-identity

# If not configured, run:
aws configure
# or
export AWS_PROFILE=your-profile
```

### Cluster Access Issues
Update your kubeconfig:
```bash
just eks-update-kubeconfig-dev
```

### Cost Monitoring
Monitor your AWS costs and remember to delete test clusters:
```bash
eksctl get clusters --region=us-east-1
just eks-delete-dev
```

## Next.js on EKS

For deploying Next.js applications on EKS, see the dedicated Next.js setup:

### Quick Start

```bash
# Create Next.js-optimized cluster
just nextjs-eks-create

# Update kubectl context
just nextjs-eks-kubeconfig

# Build the Next.js Docker image
just nextjs-build

# Deploy Next.js application
just nextjs-deploy

# Check status
just nextjs-status

# Clean up
just nextjs-delete
just nextjs-eks-delete
```

For detailed Next.js deployment instructions, see [nextjs-app/README.md](../nextjs-app/README.md).

## Learning Resources

- [eksctl Documentation](https://eksctl.io/)
- [Amazon EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)