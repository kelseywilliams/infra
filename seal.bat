@echo off

set NS=droplet
set OUT=overlays\local\secrets
set POSTGRES_PLAIN=base\postgres\secrets\plaintext
set POSTGRES_SEALED=%OUT%\postgres-secrets.sealed.yaml
set REDIS_PLAIN=base\redis\secrets\plaintext
set REDIS_SEALED=%OUT%\redis-secrets.sealed.yaml

echo Sealing postgres secrets...

if not exist "%OUT%" mkdir "%OUT%"

kubectl create secret generic postgres-secrets --namespace=%NS% ^
    --from-file=admin_pwd=%POSTGRES_PLAIN%\admin_pwd ^
    --from-file=worker_pwd=%POSTGRES_PLAIN%\worker_pwd ^
    --from-file=readonly_pwd=%POSTGRES_PLAIN%\readonly_pwd ^
    --dry-run=client -o yaml | kubeseal --format yaml > "%POSTGRES_SEALED%"

if errorlevel 1 ( echo postgres kubeseal failed. & exit /b 1 )

echo Secrets sealed to: %POSTGRES_SEALED%

echo Sealing redis secrets...
kubectl create secret generic redis-secrets --namespace=%NS% ^
    --from-file=users.acl=%REDIS_PLAIN%\users.acl ^
    --dry-run=client -o yaml | kubeseal --format yaml > "%REDIS_SEALED%"

if errorlevel 1 ( echo redis kubeseal failed. & exit /b 1 )

echo Secrets sealed to: %REDIS_SEALED%