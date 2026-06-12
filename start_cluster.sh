#!/bin/bash
set -euo pipefail

CLUSTER=droplet
CONFIG=k3d-config.prod.yaml
CONTROLLER=https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.37.0/controller.yaml

if k3d cluster list | grep -q "^$CLUSTER "; then
    echo Starting cluster $CLUSTER...
    k3d cluster start "$CLUSTER"
else
    echo Creating cluster $CLUSTER...
    k3d cluster create --config "$CONFIG"
    kubectl apply -f "$CONTROLLER"
    kubectl -n kube-system rollout status deployment/sealed-secrets-controller --timeout=120s
    rm -f overlays/prod/secrets/*.sealed.yaml
    ./seal.sh
fi

kubectl config use-context "k3d-$CLUSTER"

kubectl apply -k overlays/prod

echo Cluster started.  Run k9s to manage.