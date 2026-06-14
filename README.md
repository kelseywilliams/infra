# Kubernetes Infrastructure for kelseywilliams.co
### Dependencies
`docker` `k3d` `kubectl` `kubeseal`
### Secrets
In order to manage secrets like passwords, ACLs, and other sensitive info, a `secrets/plaintext` is to be created in the apps base folder, i.e. `base/postgres/secrets/plaintext`.  The required secrets are visible in the seal scripts.  The seal scripts take the secret files in the `secrets/plaintext` folder of each app in the `base` folder and creates a generic secret which it pipes to kubeseal to create a YAML with the encrypted secrets that is stored to either the `overlays/local/secrets` or `overlays/prod/secrets` depending on if the batch or shell was run respectively.  These YAML's with the encrypted secrets are safe for git tracking.  _Note that the secrets are signed to the cluster meaning that the keys must be regenerated for each cluster. Using the start and delete scripts outlined below is the recommended way to manage the cluster since they handle seals and seal cleanup._
### Scripts
To bring up a cluster, you can use the start cluster scripts.  These scripts check if the cluster named droplet exists or not and either starts it or creates it and seals the secrets in the latter case.  In order to stop the cluster, use k3d command `k3d cluster stop droplet`. To delete the cluster, use the delete cluster scripts in order to properly remove sealed secrets signed by that cluster.
Batch scripts write to `overlays/local`, designed for development environment.
Bash scripts write to `overlays/prod`, designed for production environment.

_FAILURE TO USE START AND DELETE SCRIPTS MAY CAUSE SEALED SECRETS TO NOT BE MANAGED PROPERLY.  This will cause pods to hang on creation and other unexpected behavior._

Seal scripts are ran by startup scripts, do not run unless `overlays/local/secrets` is empty or `overlays/prod/secrets` is empty.
### Overview
Uses k3d to create a lightweight Kubernetes cluster.  The repository contains batch scripts for startup which apply YAML to the cluster sequentially via kubectl in order to start the cluster and run website applications.  The website application YAML is separated into seperate subdirectories under `./base`.  `./base` contains the general configs that can be applied indiscriminately regardless of environment.  `./overlays` contains configs that are environment dependent. 

Uses kubeseal to create a SealedSecret named once at cluster creation.  The controller decrypts it into a Secret, which is mounted as a volume.

A `kustomization.yaml` is used in order to bundle resource YAML and application config files into a kustomization yaml that can be applied by `kubectl` making the application of config simpler.

### Current Website Applications
Below is a list of the current web applications run by the cluster.  Which applications are applied on cluster start can be edited in `start_server.bat`. Links to the repositories are provided for self owned images.

- postgres
- redis
- [api](https://github.com/kelseywilliams/api.kelseywilliams.co)