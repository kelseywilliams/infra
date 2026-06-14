#!/bin/bash
set -euo pipefail

CLUSTER=droplet
CONFIG=k3d-config.prod.yaml
CONTROLLER=https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.37.0/controller.yaml
EG_VERSION=v1.8.1
CM_VERSION=v1.20.2

if k3d cluster list | grep -q "^$CLUSTER "; then
    echo Starting cluster $CLUSTER...
    k3d cluster start "$CLUSTER"
else
    echo Creating cluster $CLUSTER...
    k3d cluster create --config "$CONFIG"
    kubectl apply -f "$CONTROLLER"
    kubectl -n kube-system rollout status deployment/sealed-secrets-controller --timeout=120s
    echo Installing Envoy Gateway and cert-manager...
    kubectl apply --server-side -f "https://github.com/envoyproxy/gateway/releases/download/$EG_VERSION/install.yaml"
    kubectl apply -f "https://github.com/cert-manager/cert-manager/releases/download/$CM_VERSION/cert-manager.yaml"
    kubectl -n envoy-gateway-system wait --for=condition=Available --timeout=300s deployment --all
    kubectl -n cert-manager wait --for=condition=Available --timeout=300s deployment --all
    kubectl apply -f base/gateway/gatewayclass.yaml
    rm -f overlays/prod/secrets/*.sealed.yaml
    ./seal.sh
fi

kubectl config use-context "k3d-$CLUSTER"

kubectl apply -k overlays/prod

echo Cluster started.  Run k9s to manage.