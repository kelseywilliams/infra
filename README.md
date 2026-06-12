# Kubernetes Infrastructure for kelseywilliams.co
### Dependencies
`docker` `k3d` `kubectl` `kubeseal`
### Secrets
In order to proteect passwords, 
### Scripts
To bring up a cluster, you can use the start cluster scripts.  These scripts check if the cluster named droplet exists or not and either starts it or creates it and seals the secrets in the latter case.  In order to stop the cluster, use k3d command `k3d cluster stop droplet`. To delete the cluster, use the delete cluster scripts in order to properly remove sealed secrets signed by that cluster.

_FAILURE TO USE START AND DELETE SCRIPTS MAY CAUSE SEALED SECRETS TO NOT BE MANAGED PROPERLY.  This will cause pods to hang on creation and other unexpected behavior._

Seal scripts are ran by startup scripts, do not run unless `overlays/local/secrets` is empty or `overlays/prod/secrets` is empty.
### Overview
Uses k3d to create a lightweight Kubernetes cluster.  The repository contains batch scripts for startup which apply YAML to the cluster sequentially via kubectl in order to start the cluster and run website applications.  The website application YAML is separated into seperate subdirectories under `./base`.  `./base` contains the general configs that can be applied indiscriminately regardless of environment.  `./overlays` contains configs that are environment dependent. 

Uses kubeseal to create a SealedSecret named once at cluster creation.  The controller decrypts it into a Secret, which is mounted as a volume.

A `kustomization.yaml` is used in order to bundle resource YAML and application config files into a kustomization that is applied to the cluster by kubectl.

### Current Website Applications
Below is a list of the current web applications run by the cluster.  Which applications are applied on cluster start can be edited in `start_server.bat`. Links to the repositories are provided for self owned images.

- postgres
- redis
