#!/bin/bash
set -euo pipefail

NS=droplet
OUT=overlays/prod/secrets
POSTGRES_PLAIN=base/postgres/secrets/plaintext
POSTGRES_SEALED=$OUT/postgres-secrets.sealed.yaml
REDIS_PLAIN=base/redis/secrets/plaintext
REDIS_SEALED=$OUT/redis-secrets.sealed.yaml

mkdir -p "$OUT"

echo "Sealing postgres secrets..."
kubectl create secret generic postgres-secrets --namespace=$NS \
    --from-file=admin_pwd=$POSTGRES_PLAIN/admin_pwd \
    --from-file=worker_pwd=$POSTGRES_PLAIN/worker_pwd \
    --from-file=readonly_pwd=$POSTGRES_PLAIN/readonly_pwd \
    --dry-run=client -o yaml | kubeseal --format yaml > "$POSTGRES_SEALED"
echo "Secrets sealed to: $POSTGRES_SEALED"

echo "Sealing redis secrets..."
kubectl create secret generic redis-secrets --namespace=$NS \
    --from-file=users.acl=$REDIS_PLAIN/users.acl \
    --dry-run=client -o yaml | kubeseal --format yaml > "$REDIS_SEALED"
echo "Secrets sealed to: $REDIS_SEALED"
