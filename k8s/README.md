# Kubernetes Configuration

This directory contains Kubernetes manifests and Kind cluster configuration for local development.

## Contents

- `kind.yaml` - Kind cluster configuration
- `manifests/` - Kubernetes manifest files

## Kind Configuration

The `kind.yaml` file defines a multi-node local Kubernetes cluster:

### Cluster Specifications

- **Cluster Name**: `platform-sandbox`
- **Kubernetes Version**: v1.30.0
- **Node Configuration**:
  - 1 control-plane node
  - 3 worker nodes

### Features

**Port Forwarding**:
The control-plane node is configured with extra port mappings to allow external access:
- Port 30080 (HTTP) - Maps to host port 30080
- Port 30443 (HTTPS) - Maps to host port 30443

These ports enable you to access NodePort services from your host machine.

**Node Labels**:
The control-plane node is labeled with `ingress-ready=true` to support ingress controllers.

## Quick Start

### Create Local Cluster

```bash
# Using just command
just kind

# Or directly with kind
kind create cluster --config k8s/kind.yaml

# Or using the init script
./init.sh
```

### Verify Cluster

```bash
# Check cluster is running
kind get clusters

# Check nodes
kubectl get nodes

# Expected output: 1 control-plane + 3 worker nodes
```

### Delete Cluster

```bash
# Using just command
just teardown

# Or directly with kind
kind delete cluster --name platform-sandbox
```

## Kubernetes Manifests

The `manifests/` directory contains Kubernetes resource definitions.

### nginx.yaml

A sample nginx deployment configuration:

**Resources**:
- **Deployment**: `nginx-deployment`
  - 1 replica
  - nginx:1.25.4 image
  - Resource limits: 0.5 CPU, 512Mi memory
  - Resource requests: 0.1 CPU, 128Mi memory
  - Liveness and readiness probes configured

**Deploy the nginx app**:
```bash
# Using just command
just nginx

# Or directly with kubectl
kubectl apply -f k8s/manifests/nginx.yaml
```

**Verify deployment**:
```bash
# Check pods
kubectl get pods -l app=nginx

# Check deployment status
kubectl get deployment nginx-deployment

# View pod details
kubectl describe pod -l app=nginx
```

**Access the application**:
```bash
# Port forward to access nginx
kubectl port-forward deployment/nginx-deployment 8080:80

# Open browser to http://localhost:8080
```

**Clean up**:
```bash
kubectl delete -f k8s/manifests/nginx.yaml
```

## Adding Custom Manifests

You can add your own Kubernetes manifests to the `manifests/` directory:

1. Create a new YAML file:
   ```yaml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: my-app
   # ... rest of your configuration
   ```

2. Apply it to the cluster:
   ```bash
   kubectl apply -f k8s/manifests/my-app.yaml
   ```

## Debugging

### Run a debug container

```bash
# Using just command
just netshoot

# Or directly with kubectl
kubectl run -it --rm --restart=Never netshoot --image nicolaka/netshoot -- bash
```

This provides a container with networking tools for debugging:
- curl, wget
- nslookup, dig
- traceroute, ping
- tcpdump, netstat
- And many more!

### View logs

```bash
# Logs from nginx deployment
kubectl logs -l app=nginx

# Follow logs
kubectl logs -f -l app=nginx

# Logs from specific pod
kubectl logs <pod-name>
```

### Execute commands in a pod

```bash
# Open shell in nginx pod
kubectl exec -it <pod-name> -- /bin/sh

# Run a single command
kubectl exec <pod-name> -- ls /usr/share/nginx/html
```

## Cluster Management

### View cluster info

```bash
# Cluster details
kubectl cluster-info

# All nodes
kubectl get nodes -o wide

# All pods in all namespaces
kubectl get pods --all-namespaces

# System pods
kubectl get pods -n kube-system
```

### Context management

```bash
# Current context
kubectl config current-context

# List all contexts
kubectl config get-contexts

# Switch context (if you have multiple clusters)
kubectl config use-context kind-platform-sandbox
```

## Why Kind?

**Advantages**:
- ✅ Free - No cloud costs
- ✅ Fast - Cluster creation in 2-3 minutes
- ✅ Local - No internet required (after initial setup)
- ✅ Realistic - Multi-node cluster mimics production
- ✅ Reproducible - Configuration as code

**Use Cases**:
- Learning Kubernetes basics
- Testing manifests before deploying to cloud
- CI/CD pipelines
- Development and testing
- Workshops and demos

## Limitations

- **Not production-ready**: Kind clusters are for local development only
- **No cloud features**: LoadBalancer services, cloud storage, etc.
- **Limited resources**: Constrained by your local machine
- **Single machine**: All nodes run on your computer

For cloud-native features, see:
- [eksctl/README.md](../eksctl/README.md) - Simple AWS EKS clusters
- [terraform/README.md](../terraform/README.md) - Infrastructure as code with Terraform

## Troubleshooting

### Cluster won't start

```bash
# Delete and recreate
kind delete cluster --name platform-sandbox
kind create cluster --config k8s/kind.yaml
```

### Docker issues

```bash
# Ensure Docker is running
docker ps

# Check Docker resources
docker system df
```

### Port conflicts

If ports 30080 or 30443 are already in use:
1. Edit `kind.yaml` and change the `hostPort` values
2. Delete and recreate the cluster

### Node not ready

```bash
# Check node status
kubectl get nodes

# Describe node to see issues
kubectl describe node <node-name>

# Check system pods
kubectl get pods -n kube-system
```

## Resources

- [Kind Documentation](https://kind.sigs.k8s.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
