#!/bin/bash
set -euo pipefail

NS=droplet
OUT=overlays/prod/secrets
POSTGRES_PLAIN=base/postgres/secrets/plaintext
POSTGRES_SEALED=$OUT/postgres-secrets.sealed.yaml
REDIS_PLAIN=base/redis/secrets/plaintext
REDIS_SEALED=$OUT/redis-secrets.sealed.yaml
API_PLAIN=base/api/secrets/plaintext
API_SEALED=$OUT/api-secrets.sealed.yaml

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

echo "Sealing api secrets..."
# postgres_worker/readonly are sourced from the POSTGRES plaintext (the values the
# cluster actually enforces), not the api repo's stale copies.
kubectl create secret generic api-secrets --namespace=$NS \
    --from-file=mailjet_api_key=$API_PLAIN/mailjet_api_key \
    --from-file=mailjet_secret=$API_PLAIN/mailjet_secret \
    --from-file=jwt_private=$API_PLAIN/jwt_private \
    --from-file=jwt_public=$API_PLAIN/jwt_public \
    --from-file=redis_secret=$API_PLAIN/redis_secret \
    --from-file=postgres_worker_secret=$POSTGRES_PLAIN/worker_pwd \
    --from-file=postgres_readonly_secret=$POSTGRES_PLAIN/readonly_pwd \
    --from-file=ADMIN=$API_PLAIN/ADMIN \
    --from-file=USER=$API_PLAIN/USER \
    --dry-run=client -o yaml | kubeseal --format yaml > "$API_SEALED"
echo "Secrets sealed to: $API_SEALED"
