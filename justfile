kind:
    #!/usr/bin/env bash
    kind create cluster --config k8s/kind.yaml

# EKS cluster management using eksctl
eks-create:
    #!/usr/bin/env bash
    eksctl create cluster -f eksctl/cluster.yaml

eks-create-dev:
    #!/usr/bin/env bash
    eksctl create cluster -f eksctl/dev-cluster.yaml

eks-delete:
    #!/usr/bin/env bash
    eksctl delete cluster --region=us-east-1 --name=my-eksctl-cluster

eks-delete-dev:
    #!/usr/bin/env bash
    eksctl delete cluster --region=us-east-1 --name=dev-eksctl-cluster

eks-update-kubeconfig:
    #!/usr/bin/env bash
    eksctl utils write-kubeconfig --cluster=my-eksctl-cluster --region=us-east-1

eks-update-kubeconfig-dev:
    #!/usr/bin/env bash
    eksctl utils write-kubeconfig --cluster=dev-eksctl-cluster --region=us-east-1

eks-nodes:
    #!/usr/bin/env bash
    eksctl get nodegroup --cluster=my-eksctl-cluster --region=us-east-1

eks-nodes-dev:
    #!/usr/bin/env bash
    eksctl get nodegroup --cluster=dev-eksctl-cluster --region=us-east-1

nginx:
    #!/usr/bin/env bash
    kubectl apply -f k8s/manifests/nginx.yaml

netshoot:
    #!/usr/bin/env bash
    kubectl run -it --rm --restart=Never netshoot --image nicolaka/netshoot -- bash

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