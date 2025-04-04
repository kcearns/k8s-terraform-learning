kind:
    #!/usr/bin/env bash
    kind create cluster --config k8s/kind.yaml

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
        echo "Run 'just cluster' to create one."
        exit 0
    else
        echo "Delete KIND cluster(s): $CLUSTER_NAME"
        kind delete clusters $CLUSTER_NAME
    fi

mysql:
    #!/usr/bin/env bash
    kubectl apply -f k8s/manifests/mysql-secret.yaml
    kubectl apply -f k8s/manifests/mysql-storage.yaml
    kubectl apply -f k8s/manifests/mysql-deployment.yaml
    kubectl apply -f k8s/manifests/mysql-service.yaml

wordpress:
    #!/usr/bin/env bash
    kubectl apply -f k8s/manifests/wordpress-service.yaml
    kubectl apply -f k8s/manifests/wordpress-deployment.yaml


