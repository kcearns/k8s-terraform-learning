# Next.js on AWS EKS - Complete Deployment Guide

This guide provides step-by-step instructions for deploying a Next.js application to AWS EKS (Elastic Kubernetes Service).

## Table of Contents

- [Prerequisites](#prerequisites)
- [Architecture Overview](#architecture-overview)
- [Quick Start](#quick-start)
- [Detailed Setup](#detailed-setup)
- [Configuration](#configuration)
- [Monitoring and Troubleshooting](#monitoring-and-troubleshooting)
- [Best Practices](#best-practices)
- [Cost Optimization](#cost-optimization)

## Prerequisites

### Required Tools

All tools are pre-installed in the devcontainer. If running locally, you'll need:

- [AWS CLI](https://aws.amazon.com/cli/) - configured with appropriate credentials
- [kubectl](https://kubernetes.io/docs/tasks/tools/) - Kubernetes command-line tool
- [eksctl](https://eksctl.io/) - EKS cluster management tool
- [Docker](https://www.docker.com/) - for building container images
- [just](https://github.com/casey/just) - command runner (optional but recommended)
- [Node.js 18+](https://nodejs.org/) - for local development

### AWS Requirements

- AWS account with appropriate permissions
- AWS credentials configured (`aws configure`)
- ECR repository for storing Docker images (optional but recommended)

## Architecture Overview

### Components

1. **EKS Cluster** (`nextjs-cluster.yaml`)
   - 2-4 t3.small nodes (Next.js needs more memory than nginx)
   - Managed node groups with auto-scaling
   - VPC with public and private subnets

2. **Next.js Application** (`nextjs-app/`)
   - Next.js 14 with App Router
   - TypeScript support
   - Health check endpoint at `/api/health`
   - Standalone output for optimal Docker deployment

3. **Docker Image** (`Dockerfile.nextjs`)
   - Multi-stage build for minimal image size
   - Non-root user for security
   - Optimized for production

4. **Kubernetes Resources** (`nextjs.yaml`)
   - Deployment with 2 replicas
   - Service (ClusterIP)
   - Ingress with AWS ALB
   - HorizontalPodAutoscaler
   - ConfigMap for environment variables
   - ServiceAccount with IRSA support

## Quick Start

### 1. Create the EKS Cluster

```bash
# Create Next.js-optimized EKS cluster (takes 15-20 minutes)
just nextjs-eks-create

# Update kubectl context
just nextjs-eks-kubeconfig

# Verify cluster
kubectl get nodes
```

### 2. Install AWS Load Balancer Controller

The AWS Load Balancer Controller is required for the Ingress to work:

```bash
# Add the EKS chart repo
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install the AWS Load Balancer Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=nextjs-eksctl-cluster \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller
```

### 3. Build and Push Docker Image

#### Using AWS ECR (Recommended)

```bash
# Set your AWS account ID and region
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=us-east-1

# Create ECR repository
aws ecr create-repository \
  --repository-name nextjs-app \
  --region $AWS_REGION

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build the image
just nextjs-build

# Tag for ECR
docker tag nextjs-app:latest \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/nextjs-app:latest

# Push to ECR
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/nextjs-app:latest
```

#### Using Docker Hub

```bash
# Login to Docker Hub
docker login

# Build and tag
just nextjs-build
docker tag nextjs-app:latest your-dockerhub-username/nextjs-app:latest

# Push
docker push your-dockerhub-username/nextjs-app:latest
```

### 4. Update Kubernetes Manifests

Edit `k8s/manifests/nextjs.yaml` and update the image reference:

```yaml
spec:
  containers:
  - name: nextjs
    image: YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/nextjs-app:latest
    # or
    # image: your-dockerhub-username/nextjs-app:latest
```

### 5. Deploy to Kubernetes

```bash
# Deploy the application
just nextjs-deploy

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=nextjs -n nextjs-app --timeout=300s

# Check status
just nextjs-status
```

### 6. Access the Application

```bash
# Get the ALB DNS name (wait a few minutes for ALB to provision)
kubectl get ingress nextjs-ingress -n nextjs-app

# Or use port-forwarding for immediate access
kubectl port-forward -n nextjs-app svc/nextjs-service 3000:80

# Open http://localhost:3000 in your browser
```

## Detailed Setup

### Customizing the Next.js Application

#### Local Development

```bash
cd nextjs-app

# Install dependencies
npm install

# Run development server
npm run dev

# Visit http://localhost:3000
```

#### Adding Environment Variables

1. **For build-time variables**, add to `next.config.js`:
   ```javascript
   module.exports = {
     env: {
       CUSTOM_KEY: process.env.CUSTOM_KEY,
     },
   }
   ```

2. **For runtime variables**, update the ConfigMap in `k8s/manifests/nextjs.yaml`:
   ```yaml
   apiVersion: v1
   kind: ConfigMap
   metadata:
     name: nextjs-config
     namespace: nextjs-app
   data:
     NODE_ENV: "production"
     API_URL: "https://api.example.com"
     CUSTOM_KEY: "custom-value"
   ```

3. **For secrets**, use Kubernetes Secrets:
   ```bash
   kubectl create secret generic nextjs-secrets \
     --from-literal=database-url=postgresql://user:pass@host:5432/db \
     --from-literal=api-key=your-secret-key \
     -n nextjs-app
   ```

   Then reference in the deployment:
   ```yaml
   env:
   - name: DATABASE_URL
     valueFrom:
       secretKeyRef:
         name: nextjs-secrets
         key: database-url
   ```

### Customizing the Cluster

Edit `eksctl/nextjs-cluster.yaml` to adjust:

- **Instance type**: Change `instanceType: t3.small` to `t3.medium` or larger for more resources
- **Node count**: Adjust `minSize`, `maxSize`, and `desiredCapacity`
- **Region**: Change `region: us-east-1` to your preferred region
- **Add-ons**: Enable/disable specific EKS add-ons

### Setting Up SSL/TLS

1. **Create or import a certificate in ACM**:
   ```bash
   aws acm request-certificate \
     --domain-name example.com \
     --validation-method DNS \
     --region us-east-1
   ```

2. **Update the Ingress** in `k8s/manifests/nextjs.yaml`:
   ```yaml
   metadata:
     annotations:
       alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:xxx:certificate/xxx
       alb.ingress.kubernetes.io/ssl-redirect: '443'
   ```

3. **Update DNS** to point to the ALB DNS name

## Configuration

### Horizontal Pod Autoscaler (HPA)

The deployment includes an HPA that scales based on CPU and memory:

```bash
# View HPA status
kubectl get hpa -n nextjs-app

# Edit HPA settings
kubectl edit hpa nextjs-hpa -n nextjs-app
```

Adjust scaling thresholds in `k8s/manifests/nextjs.yaml`:
```yaml
metrics:
- type: Resource
  resource:
    name: cpu
    target:
      type: Utilization
      averageUtilization: 70  # Scale when CPU > 70%
```

### Resource Limits

Adjust resource limits based on your application's needs:

```yaml
resources:
  limits:
    cpu: "1"        # Increase for CPU-intensive operations
    memory: "1Gi"   # Increase for large applications
  requests:
    cpu: "250m"
    memory: "512Mi"
```

### IAM Roles for Service Accounts (IRSA)

To give your Next.js pods AWS permissions:

1. **Create IAM policy** with required permissions
2. **Create IAM role** and associate with service account:
   ```bash
   eksctl create iamserviceaccount \
     --name nextjs-service-account \
     --namespace nextjs-app \
     --cluster nextjs-eksctl-cluster \
     --attach-policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess \
     --approve \
     --override-existing-serviceaccounts
   ```

3. **Update ServiceAccount** annotation in `k8s/manifests/nextjs.yaml`

## Monitoring and Troubleshooting

### Viewing Logs

```bash
# Stream logs from all Next.js pods
just nextjs-logs

# View logs from a specific pod
kubectl logs -n nextjs-app pod-name

# View previous container logs (if pod crashed)
kubectl logs -n nextjs-app pod-name --previous
```

### Checking Application Health

```bash
# Test health endpoint
kubectl port-forward -n nextjs-app svc/nextjs-service 3000:80
curl http://localhost:3000/api/health

# Expected response:
# {
#   "status": "healthy",
#   "timestamp": "2024-01-01T00:00:00.000Z",
#   "environment": "production",
#   "uptime": 123.456
# }
```

### Common Issues

#### Pods not starting

```bash
# Check pod status
kubectl describe pod -n nextjs-app -l app=nextjs

# Common causes:
# - Image pull errors: Check image name and registry credentials
# - Resource limits: Pods may be pending if cluster is out of resources
# - Configuration errors: Check environment variables and secrets
```

#### Image pull errors

```bash
# For ECR, ensure nodes have permissions:
# The managed node group should have the AmazonEC2ContainerRegistryReadOnly policy

# For private registries, create a pull secret:
kubectl create secret docker-registry regcred \
  --docker-server=your-registry.com \
  --docker-username=username \
  --docker-password=password \
  -n nextjs-app

# Then add to deployment:
# spec:
#   imagePullSecrets:
#   - name: regcred
```

#### Ingress not working

```bash
# Check ingress status
kubectl describe ingress nextjs-ingress -n nextjs-app

# Verify ALB Controller is running
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Check ALB in AWS Console
# - Ensure target groups are healthy
# - Check security groups allow traffic on port 80/443
```

### Performance Monitoring

```bash
# View resource usage
kubectl top pods -n nextjs-app
kubectl top nodes

# Check HPA metrics
kubectl get hpa nextjs-hpa -n nextjs-app --watch
```

## Best Practices

### Security

1. **Use non-root containers**: Already configured in `Dockerfile.nextjs`
2. **Store secrets in Kubernetes Secrets**: Never hardcode sensitive data
3. **Enable RBAC**: Limit service account permissions
4. **Use network policies**: Restrict pod-to-pod communication
5. **Scan images**: Use tools like Trivy or Snyk
6. **Enable Pod Security Standards**: Add to namespace:
   ```yaml
   apiVersion: v1
   kind: Namespace
   metadata:
     name: nextjs-app
     labels:
       pod-security.kubernetes.io/enforce: restricted
   ```

### Deployment

1. **Use specific image tags**: Avoid `:latest` in production
2. **Implement health checks**: Already configured in manifests
3. **Set resource limits**: Prevent resource exhaustion
4. **Use rolling updates**: Configure deployment strategy:
   ```yaml
   spec:
     strategy:
       type: RollingUpdate
       rollingUpdate:
         maxSurge: 1
         maxUnavailable: 0
   ```
5. **Test in staging first**: Create a separate cluster for testing

### Performance

1. **Enable caching**: Configure Next.js caching strategies
2. **Use CDN**: CloudFront with ALB as origin
3. **Optimize images**: Use Next.js Image component
4. **Monitor metrics**: Set up CloudWatch or Prometheus
5. **Right-size resources**: Monitor and adjust CPU/memory

## Cost Optimization

### Estimated Monthly Costs (us-east-1)

- **EKS Control Plane**: ~$73/month
- **EC2 Nodes** (2x t3.small): ~$30/month
- **ALB**: ~$17/month + data transfer
- **EBS Volumes**: ~$6/month (60GB total)
- **Data Transfer**: Variable based on usage
- **Total**: ~$126/month minimum

### Cost Reduction Tips

1. **Use Fargate Spot**: For non-production workloads
2. **Auto-scaling**: Scale to zero during off-hours if possible
3. **Reserved Instances**: For long-term production workloads
4. **Monitor and optimize**: Use AWS Cost Explorer
5. **Delete unused resources**: 
   ```bash
   # Always delete test clusters
   just nextjs-eks-delete
   ```

### Development Setup

For learning and development, consider:

1. **Use Kind locally**: Free local Kubernetes
   ```bash
   just kind
   just nextjs-deploy  # After building image
   ```

2. **Use dev-cluster**: Smaller, cheaper EKS cluster
   ```bash
   just eks-create-dev  # Uses t3.micro instead of t3.small
   ```

## Cleanup

### Delete Application Only

```bash
just nextjs-delete
```

### Delete Everything

```bash
# Delete application
just nextjs-delete

# Delete cluster (this will take several minutes)
just nextjs-eks-delete

# Delete ECR repository (optional)
aws ecr delete-repository \
  --repository-name nextjs-app \
  --region us-east-1 \
  --force
```

## Next Steps

1. **Set up CI/CD**: Automate builds and deployments
2. **Add monitoring**: Integrate with CloudWatch, Prometheus, or Datadog
3. **Configure backups**: For any persistent data
4. **Implement logging**: Centralized logging with CloudWatch Logs or ELK
5. **Set up alerts**: Monitor application health and performance
6. **Documentation**: Document your specific configuration and procedures

## Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [eksctl Documentation](https://eksctl.io/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [Next.js Deployment Documentation](https://nextjs.org/docs/deployment)
