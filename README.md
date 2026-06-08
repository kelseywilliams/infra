# Kubernetes Infrastructure for kelseywilliams.co

### Overview
Uses k3d to create a Kubernetes cluster.  The repository contains batch scripts for startup which apply YAML to the cluster sequentially via kubectl.  Below is the current list of implemented apps.

## Postgres
### Sealed Secrets
Uses kubeseal to create a SealedSecret named postgres-secrets once at cluster creation.  The controller decrypts it into a Secret, which is mounted as a volume.
### Kustomize
The StatefulSet uses Kustomize to bundle app configuration files and Kubernetes manifests.