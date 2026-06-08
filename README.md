# Kubernetes Infrastructure for kelseywilliams.co
### Dependencies
`k3d` `kubectl` `kubeseal`
### Overview
Uses k3d to create a Kubernetes cluster.  The repository contains batch scripts for startup which apply YAML to the cluster sequentially via kubectl in order to start the cluster and run webiste applications.  The website application YAML is separated into seperate subdirectories under `./base`.  `./base` contains the general configs that can be applied indiscriminately regardless of environment.  `./overlays` contains configs that are environment dependent. 

### Sealed Secrets
Uses kubeseal to create a SealedSecret named once at cluster creation.  The controller decrypts it into a Secret, which is mounted as a volume.
### Kustomize
A `kustomization.yaml` is used in order to bundle resource YAML and application config files into a kustomization that is applied to the cluster by kubectl.

### Website Applications
Below is a list of the current web applications run by the cluster.  Which applications are applied on cluster start can be edited in `start_server.bat`. Links to the repositories are provided for self owned images.

- postgres
- redis
