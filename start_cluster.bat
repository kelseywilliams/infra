@echo off

set CLUSTER=droplet
set CONFIG=k3d-config.local.yaml
set CONTROLLER=https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.37.0/controller.yaml
set EG_VERSION=v1.8.1

k3d cluster list | findstr /b /c:"%CLUSTER%" >nul
if errorlevel 1 (
    echo Creating cluster %CLUSTER%...
    k3d cluster create --config %CONFIG%
    kubectl apply -f %CONTROLLER%
    kubectl -n kube-system rollout status deployment/sealed-secrets-controller --timeout=120s
    echo Installing Envoy Gateway...
    kubectl apply --server-side -f https://github.com/envoyproxy/gateway/releases/download/%EG_VERSION%/install.yaml
    kubectl -n envoy-gateway-system wait --for=condition=Available --timeout=300s deployment --all
    kubectl apply -f base/gateway/gatewayclass.yaml
    del /q overlays\local\secrets\*.sealed.yaml
    call seal.bat
) else (
    echo Starting cluster %CLUSTER%...
    k3d cluster start %CLUSTER%
)

kubectl config use-context k3d-%CLUSTER%

kubectl apply -k overlays/local

echo Cluster started.  Run k9s to manage.