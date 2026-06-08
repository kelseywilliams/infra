@echo off

set CLUSTER=droplet
set NS=droplet
set CONFIG=k3d-config.local.yaml
set SEALED=overlays\local\secrets\postgres-secrets.sealed.yaml
set CONTROLLER=https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.37.0/controller.yaml

k3d cluster list | findstr /b /c:"%CLUSTER%"
if errorlevel 1 (
    echo %CLUSTER% does not exist.  Creating...
    k3d cluster create --config %CONFIG%
) else (
    echo Starting cluster %CLUSTER%...
    k3d cluster start %CLUSTER%
)

kubectl config use-context k3d-%CLUSTER%

kubectl wait --for=condition=Ready nodes --all --timeout=90s

kubectl apply -f %CONTROLLER%
kubectl -n kube-system rollout status deployment/sealed-secrets-controller --timeout=120s

kubectl apply -f base/namespace.yaml

if not exist "%SEALED%" (
    echo %SEALED% does not exist.  Running seal.bat
    call seal.bat
)

echo Applying seals
kubectl apply -f "%SEALED%"


kubectl apply -k base/postgres

echo ************* Server start complete *************