#!/bin/bash
set -euo pipefail

CLUSTER=droplet
NS=droplet
CONFIG=k3d-config.prod.yaml
OVERLAY=overlays/prod/secrets
POSTGRES_SEALED=$OVERLAY/postgres-secrets.sealed.yaml
REDIS_SEALED=$OVERLAY/redis-secrets.sealed.yaml
CONTROLLER=https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.37.0/controller.yaml

if k3d cluster list | grep $CLUSTER; then
    echo Starting cluster $CLUSTER
    k3d cluster start $CLUSTER
else
    echo $CLUSTER does not exist. Creating...
    k3d cluster create --config $CONFIG
fi

kubectl config use-context k3d-$CLUSTER

kubectl wait --for=condition=Ready nodes --all --timeout=90s

kubectl apply -f $CONTROLLER
kubectl -n kube-system rollout status deployment/sealed-secrets-controller --timeout=120s

if [ ! -f "$POSTGRES_SEALED" ] || [ ! -f "$REDIS_SEALED" ]; then
    echo "Sealed secrets missing. Running seal.sh..."
    ./seal.sh
fi

kubectl apply -k overlays/prod

echo "************* Server start complete *************"
