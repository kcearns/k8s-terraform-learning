# Create local Kind cluster for development
kind:
    #!/usr/bin/env bash
    kind create cluster --config k8s/kind.yaml

# EKS cluster management using eksctl

# Create production EKS cluster (higher cost)
eks-create:
    #!/usr/bin/env bash
    eksctl create cluster -f eksctl/cluster.yaml

# Create development EKS cluster (cost-optimized)
eks-create-dev:
    #!/usr/bin/env bash
    eksctl create cluster -f eksctl/dev-cluster.yaml

# Delete production EKS cluster
eks-delete:
    #!/usr/bin/env bash
    eksctl delete cluster --region=us-east-1 --name=my-eksctl-cluster

# Delete development EKS cluster
eks-delete-dev:
    #!/usr/bin/env bash
    eksctl delete cluster --region=us-east-1 --name=dev-eksctl-cluster

# Update kubectl context for production cluster
eks-update-kubeconfig:
    #!/usr/bin/env bash
    eksctl utils write-kubeconfig --cluster=my-eksctl-cluster --region=us-east-1

# Update kubectl context for development cluster
eks-update-kubeconfig-dev:
    #!/usr/bin/env bash
    eksctl utils write-kubeconfig --cluster=dev-eksctl-cluster --region=us-east-1

# List node groups in production cluster
eks-nodes:
    #!/usr/bin/env bash
    eksctl get nodegroup --cluster=my-eksctl-cluster --region=us-east-1

# List node groups in development cluster
eks-nodes-dev:
    #!/usr/bin/env bash
    eksctl get nodegroup --cluster=dev-eksctl-cluster --region=us-east-1

# Deploy sample nginx application to current cluster
nginx:
    #!/usr/bin/env bash
    kubectl apply -f k8s/manifests/nginx.yaml

# Run interactive debugging container with network tools
netshoot:
    #!/usr/bin/env bash
    kubectl run -it --rm --restart=Never netshoot --image nicolaka/netshoot -- bash

# Next.js EKS cluster management

# Create Next.js-optimized EKS cluster
nextjs-eks-create:
    #!/usr/bin/env bash
    eksctl create cluster -f eksctl/nextjs-cluster.yaml

# Delete Next.js EKS cluster
nextjs-eks-delete:
    #!/usr/bin/env bash
    eksctl delete cluster --region=us-east-1 --name=nextjs-eksctl-cluster

# Update kubectl context for Next.js cluster
nextjs-eks-kubeconfig:
    #!/usr/bin/env bash
    eksctl utils write-kubeconfig --cluster=nextjs-eksctl-cluster --region=us-east-1

# Build Next.js Docker image
nextjs-build:
    #!/usr/bin/env bash
    docker build -f docker/Dockerfile.nextjs -t nextjs-app:latest ./nextjs-app

# Deploy Next.js application to current cluster
nextjs-deploy:
    #!/usr/bin/env bash
    kubectl apply -f k8s/manifests/nextjs.yaml

# Delete Next.js application from cluster
nextjs-delete:
    #!/usr/bin/env bash
    kubectl delete -f k8s/manifests/nextjs.yaml

# View Next.js application logs
nextjs-logs:
    #!/usr/bin/env bash
    kubectl logs -f -n nextjs-app -l app=nextjs

# Get Next.js application status
nextjs-status:
    #!/usr/bin/env bash
    echo "=== Pods ===" && \
    kubectl get pods -n nextjs-app && \
    echo "" && \
    echo "=== Service ===" && \
    kubectl get svc -n nextjs-app && \
    echo "" && \
    echo "=== Ingress ===" && \
    kubectl get ingress -n nextjs-app

# Delete local Kind cluster
teardown:
    #!/usr/bin/env bash
    CLUSTER_NAME=$(kind get clusters)

    if [ -z "$CLUSTER_NAME" ]; then
        echo "Run 'just kind' to create one."
        exit 0
    else
        echo "Delete KIND cluster(s): $CLUSTER_NAME"
        kind delete clusters $CLUSTER_NAME
    fi