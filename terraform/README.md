# EKS Terraform Configuration

This directory contains Terraform configuration for creating a basic Amazon EKS (Elastic Kubernetes Service) cluster using existing subnets in supported availability zones.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- AWS CLI configured with appropriate credentials
- kubectl (to interact with the cluster after creation)

## Configuration

The main configuration is defined in these files:

- `main.tf`: Main EKS cluster configuration
- `variables.tf`: Input variables with default values
- `versions.tf`: Required Terraform and provider versions

## What This Does

- Uses existing subnets in the default VPC from supported EKS availability zones (us-east-1a, us-east-1b, us-east-1c)
- Tags the subnets for Kubernetes functionality
- Creates an EKS cluster with managed node groups

## Usage

1. Initialize Terraform:

```bash
terraform init
```

2. Review the plan:

```bash
terraform plan
```

3. Apply the configuration:

```bash
terraform apply
```

4. After successful creation, configure kubectl:

```bash
aws eks update-kubeconfig --region $(terraform output -raw region) --name $(terraform output -raw cluster_name)
```

5. Verify the connection:

```bash
kubectl get nodes
```

## Customization

You can customize the cluster by modifying the variables in `terraform.tfvars` (create this file) or by passing variables on the command line:

```bash
terraform apply -var="cluster_name=my-custom-cluster" -var="region=us-east-1"
```

## Troubleshooting

### Availability Zone Issues

This configuration specifically selects existing subnets from supported availability zones (us-east-1a, us-east-1b, us-east-1c) since EKS does not support creating control plane instances in all availability zones (such as us-east-1e).

## Clean Up

To destroy all resources:

```bash
terraform destroy
``` 