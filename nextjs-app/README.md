# Next.js Application for AWS EKS

This is a sample Next.js application configured for deployment on AWS EKS (Elastic Kubernetes Service).

## Features

- ✅ Next.js 14 with App Router
- ✅ TypeScript support
- ✅ Production-optimized Docker build
- ✅ Health check endpoint (`/api/health`)
- ✅ Kubernetes-ready configuration
- ✅ Multi-stage Docker build for minimal image size
- ✅ Security headers configured

## Local Development

### Prerequisites

- Node.js 18 or higher
- npm or yarn

### Getting Started

1. **Install dependencies:**
   ```bash
   cd nextjs-app
   npm install
   ```

2. **Run the development server:**
   ```bash
   npm run dev
   ```

3. **Open your browser:**
   Navigate to [http://localhost:3000](http://localhost:3000)

## Building for Production

### Build the Next.js application

```bash
npm run build
npm start
```

### Build Docker image

From the repository root:

```bash
docker build -f docker/Dockerfile.nextjs -t nextjs-app:latest ./nextjs-app
```

### Test the Docker image locally

```bash
docker run -p 3000:3000 nextjs-app:latest
```

## Deploying to AWS EKS

### 1. Create an EKS cluster

```bash
# Create Next.js-optimized EKS cluster
just nextjs-eks-create

# Or manually with eksctl
eksctl create cluster -f eksctl/nextjs-cluster.yaml
```

### 2. Build and push Docker image

```bash
# Tag your image
docker tag nextjs-app:latest YOUR_REGISTRY/nextjs-app:latest

# Push to your container registry
docker push YOUR_REGISTRY/nextjs-app:latest
```

For AWS ECR:
```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Create repository
aws ecr create-repository --repository-name nextjs-app --region us-east-1

# Tag and push
docker tag nextjs-app:latest ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/nextjs-app:latest
docker push ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/nextjs-app:latest
```

### 3. Update Kubernetes manifests

Edit `k8s/manifests/nextjs.yaml` and replace:
```yaml
image: your-registry/nextjs-app:latest
```
with your actual image location.

### 4. Deploy to Kubernetes

```bash
# Deploy the application
just nextjs-deploy

# Or manually with kubectl
kubectl apply -f k8s/manifests/nextjs.yaml
```

### 5. Verify deployment

```bash
# Check pods
kubectl get pods -n nextjs-app

# Check service
kubectl get svc -n nextjs-app

# Get ingress URL
kubectl get ingress -n nextjs-app
```

### 6. Access the application

If using AWS ALB Ingress Controller:
```bash
# Get the ALB DNS name
kubectl get ingress nextjs-ingress -n nextjs-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Or use port-forwarding for testing:
```bash
kubectl port-forward -n nextjs-app svc/nextjs-service 3000:80
```

Then open [http://localhost:3000](http://localhost:3000)

## Environment Variables

Add environment variables in the ConfigMap (`k8s/manifests/nextjs.yaml`):

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nextjs-config
  namespace: nextjs-app
data:
  NODE_ENV: "production"
  # Add your variables here
  API_URL: "https://api.example.com"
```

For sensitive data, use Kubernetes Secrets:

```bash
kubectl create secret generic nextjs-secrets \
  --from-literal=database-url=postgresql://user:pass@host:5432/db \
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

## Monitoring

### Health Check

The application includes a health check endpoint at `/api/health`:

```bash
curl http://your-app-url/api/health
```

Response:
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "environment": "production",
  "uptime": 123.456
}
```

### Logs

View application logs:
```bash
kubectl logs -f -n nextjs-app -l app=nextjs
```

## Scaling

The deployment includes a Horizontal Pod Autoscaler (HPA):

```bash
# Check HPA status
kubectl get hpa -n nextjs-app

# Manually scale
kubectl scale deployment nextjs-deployment -n nextjs-app --replicas=5
```

## Cleanup

### Delete the application

```bash
kubectl delete -f k8s/manifests/nextjs.yaml
```

### Delete the EKS cluster

```bash
just nextjs-eks-delete

# Or manually
eksctl delete cluster --region=us-east-1 --name=nextjs-eksctl-cluster
```

## Troubleshooting

### Pod not starting

```bash
# Check pod status
kubectl describe pod -n nextjs-app -l app=nextjs

# Check logs
kubectl logs -n nextjs-app -l app=nextjs
```

### Image pull errors

Ensure:
1. Image exists in your registry
2. ImagePullSecrets are configured if using private registry
3. EKS nodes have permission to pull from ECR

### Health check failing

Test locally:
```bash
kubectl port-forward -n nextjs-app svc/nextjs-service 3000:80
curl http://localhost:3000/api/health
```

## Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [eksctl Documentation](https://eksctl.io/)
