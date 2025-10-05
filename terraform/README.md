# EKS Terraform Configuration

This directory contains Terraform configuration for creating a basic Amazon EKS (Elastic Kubernetes Service) cluster using existing subnets in supported availability zones.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- AWS CLI configured with appropriate credentials
- kubectl (to interact with the cluster after creation)
- Appropriate AWS IAM permissions to create EKS clusters, VPCs, and IAM roles

## Configuration Files

The Terraform configuration is organized into these files:

### main.tf

The main configuration file that defines:
- **Data Sources**: Queries for existing VPC and subnets in supported availability zones
- **Subnet Tagging**: Tags existing subnets for Kubernetes to use them for load balancers and ingress
- **EKS Cluster**: Creates the EKS control plane
- **EKS Node Group**: Creates managed worker nodes
- **Outputs**: Exposes cluster information for use with kubectl

### variables.tf

Configurable input variables with sensible defaults:

| Variable | Default | Description |
|----------|---------|-------------|
| `region` | `us-east-1` | AWS region for the cluster |
| `cluster_name` | `my-eks-test-cluster` | Name of the EKS cluster |
| `cluster_version` | `1.33` | Kubernetes version |
| `instance_types` | `["t2.micro"]` | EC2 instance types for nodes |
| `min_size` | `1` | Minimum number of nodes |
| `max_size` | `3` | Maximum number of nodes |
| `desired_size` | `2` | Desired number of nodes |

### versions.tf

Specifies required Terraform and provider versions:
- Terraform >= 1.0
- AWS Provider ~> 5.0

## What This Configuration Does

1. **Finds Existing Infrastructure**:
   - Locates your default VPC
   - Identifies subnets in supported availability zones (us-east-1a, us-east-1b, us-east-1c)
   - Filters out us-east-1e (not supported by EKS in some regions)

2. **Tags Subnets**:
   - Adds `kubernetes.io/cluster/<cluster-name>` tag for Kubernetes to discover subnets
   - Required for LoadBalancer services and ingress controllers

3. **Creates EKS Cluster**:
   - Control plane in the specified subnets
   - Public and private endpoint access
   - Kubernetes version 1.33 by default

4. **Creates Managed Node Group**:
   - t2.micro instances (free tier eligible)
   - Auto-scaling between 1-3 nodes
   - 2 nodes by default
   - Automatic security group configuration

5. **Outputs Information**:
   - Cluster name
   - Cluster endpoint
   - AWS region

## Usage

### Initial Setup

Navigate to the terraform directory:

```bash
cd terraform
```

### Step 1: Initialize Terraform

Download required providers and modules:

```bash
terraform init
```

Expected output:
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
Terraform has been successfully initialized!
```

### Step 2: Review the Plan

Preview what Terraform will create:

```bash
terraform plan
```

This will show:
- Resources to be created (EKS cluster, node group, IAM roles, etc.)
- Estimated cost information (if using cost estimation tools)

### Step 3: Apply the Configuration

Create the resources:

```bash
terraform apply
```

Type `yes` when prompted to confirm.

**Note**: This will take approximately 15-20 minutes to complete.

### Step 4: Configure kubectl

After successful creation, configure kubectl to use your new cluster:

```bash
aws eks update-kubeconfig --region $(terraform output -raw region) --name $(terraform output -raw cluster_name)
```

Or manually:

```bash
aws eks update-kubeconfig --region us-east-1 --name my-eks-test-cluster
```

### Step 5: Verify Connection

Test your connection to the cluster:

```bash
# Check nodes
kubectl get nodes

# Check system pods
kubectl get pods -n kube-system

# Check cluster info
kubectl cluster-info
```

Expected output:
```
NAME                          STATUS   ROLES    AGE   VERSION
ip-10-0-1-100.ec2.internal    Ready    <none>   5m    v1.33.0
ip-10-0-2-100.ec2.internal    Ready    <none>   5m    v1.33.0
```

## Customization

### Using terraform.tfvars

Create a `terraform.tfvars` file to customize your cluster:

```hcl
# terraform.tfvars
region         = "us-west-2"
cluster_name   = "my-production-cluster"
cluster_version = "1.33"
instance_types = ["t3.medium"]
min_size       = 2
max_size       = 5
desired_size   = 3
```

Then apply:

```bash
terraform apply
```

### Command-Line Variables

Override variables on the command line:

```bash
terraform apply \
  -var="cluster_name=my-custom-cluster" \
  -var="region=us-west-2" \
  -var="desired_size=3"
```

### Common Customizations

**Use larger instances**:
```bash
terraform apply -var='instance_types=["t3.medium"]'
```

**Scale up the cluster**:
```bash
terraform apply -var="min_size=3" -var="max_size=6" -var="desired_size=4"
```

**Change Kubernetes version**:
```bash
terraform apply -var="cluster_version=1.32"
```

## State Management

Terraform stores state in `terraform.tfstate` (local backend by default).

### Important State Commands

```bash
# Show current state
terraform show

# List all resources in state
terraform state list

# Show specific resource
terraform state show aws_eks_cluster.main

# Refresh state from AWS
terraform refresh
```

### Remote State (Recommended for Teams)

For production or team environments, use remote state:

```hcl
# backend.tf
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt = true
  }
}
```

## Outputs

After applying, Terraform provides outputs:

```bash
# Show all outputs
terraform output

# Show specific output
terraform output cluster_name
terraform output -raw cluster_endpoint
```

Use outputs in scripts:

```bash
CLUSTER_NAME=$(terraform output -raw cluster_name)
REGION=$(terraform output -raw region)
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
```

## Cost Estimation

Before creating resources, estimate costs:

**EKS Control Plane**: $0.10/hour (~$73/month)
**Worker Nodes (t2.micro)**: $0.0116/hour per node (~$8.50/month per node)
**Data Transfer**: Variable based on usage
**EBS Volumes**: $0.10/GB-month (20GB per node default)

**Estimated monthly cost** (2 t2.micro nodes): ~$90/month

💡 **Cost-saving tips**:
- Use t2.micro or t3.micro for development
- Scale down to 1 node for testing
- Delete clusters when not in use
- Use spot instances (requires additional configuration)

## Troubleshooting

### Availability Zone Issues

This configuration specifically selects subnets from us-east-1a, us-east-1b, and us-east-1c. EKS doesn't support all availability zones.

**Error**: "UnsupportedAvailabilityZoneException"
**Solution**: The configuration already filters out unsupported zones like us-east-1e

### No Subnets Found

**Error**: "Error: no matching subnet found"
**Solution**: 
1. Ensure you have a default VPC:
   ```bash
   aws ec2 describe-vpcs --filters Name=isDefault,Values=true
   ```
2. Or create subnets in supported AZs first

### IAM Permission Errors

**Error**: "AccessDeniedException" or "UnauthorizedException"
**Solution**: Ensure your AWS credentials have these permissions:
- eks:CreateCluster
- eks:CreateNodegroup
- iam:CreateRole
- iam:AttachRolePolicy
- ec2:DescribeVpcs
- ec2:DescribeSubnets
- ec2:CreateTags

### Cluster Creation Timeout

If creation takes longer than expected:

```bash
# Check cluster status in AWS Console or CLI
aws eks describe-cluster --name my-eks-test-cluster --region us-east-1

# Wait for cluster to be active
aws eks wait cluster-active --name my-eks-test-cluster --region us-east-1
```

### Cannot Connect to Cluster

**Issue**: kubectl commands fail after terraform apply

**Solutions**:
1. Update kubeconfig:
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name my-eks-test-cluster
   ```

2. Verify AWS credentials:
   ```bash
   aws sts get-caller-identity
   ```

3. Check cluster status:
   ```bash
   aws eks describe-cluster --name my-eks-test-cluster --region us-east-1
   ```

## Upgrading

### Upgrade Kubernetes Version

1. Update the variable:
   ```bash
   terraform apply -var="cluster_version=1.34"
   ```

2. Upgrade node group:
   - Terraform will show changes to the node group
   - Nodes will be replaced (rolling update)

### Upgrade Terraform Providers

```bash
# Update provider versions
terraform init -upgrade

# Review changes
terraform plan

# Apply if needed
terraform apply
```

## Clean Up

### Destroy All Resources

⚠️ **Warning**: This will delete your EKS cluster and all associated resources!

```bash
terraform destroy
```

Type `yes` when prompted.

**Important**: 
- Delete any LoadBalancer services first (they create AWS resources outside Terraform)
- Delete any persistent volumes
- Check AWS Console to ensure all resources are removed

### Delete Specific Resources

```bash
# Remove from Terraform management (but keep in AWS)
terraform state rm aws_eks_node_group.main

# Destroy specific resource
terraform destroy -target=aws_eks_node_group.main
```

## Comparison with eksctl

| Feature | Terraform | eksctl |
|---------|-----------|--------|
| **Learning Curve** | Steep | Easy |
| **Customization** | High | Medium |
| **Infrastructure as Code** | Yes | YAML configs |
| **State Management** | Yes | No |
| **VPC Management** | Full control | Automatic |
| **Best For** | Production, custom setups | Quick prototypes |

See [CLUSTER-COMPARISON.md](../CLUSTER-COMPARISON.md) for detailed comparison.

## Next Steps

After creating your cluster:

1. **Deploy applications**: Use the manifests in `k8s/manifests/`
   ```bash
   kubectl apply -f ../k8s/manifests/nginx.yaml
   ```

2. **Set up monitoring**: Install Kubernetes Dashboard or Prometheus
   
3. **Configure ingress**: Install an ingress controller like nginx-ingress

4. **Set up CI/CD**: Integrate with GitHub Actions or Jenkins

## Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Amazon EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html) 