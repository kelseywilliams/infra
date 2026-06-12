@echo off

set CLUSTER=droplet
set CONFIG=k3d-config.local.yaml
set CONTROLLER=https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.37.0/controller.yaml

k3d cluster list | findstr /b /c:"%CLUSTER%" >nul
if errorlevel 1 (
    echo Creating cluster %CLUSTER%...
    k3d cluster create --config %CONFIG%
    kubectl apply -f %CONTROLLER%
    kubectl -n kube-system rollout status deployment/sealed-secrets-controller --timeout=120s
    del /q overlays\local\secrets\*.sealed.yaml
    call seal.bat
) else (
    echo Starting cluster %CLUSTER%...
    k3d cluster start %CLUSTER%
)

kubectl config use-context k3d-%CLUSTER%

kubectl apply -k overlays/local

echo Cluster started.  Run k9s to manage.