@echo off

set NS=droplet
set OUT=overlays\local\secrets
set PLAIN=base\postgres\secrets\plaintext
set SEALED=%OUT%\postgres-secrets.sealed.yaml

echo Sealing postgres secrets...

if not exist "%OUT%" mkdir "%OUT%"

kubectl create secret generic postgres-secrets --namespace=%NS% ^
    --from-file=admin_pwd=%PLAIN%\admin_pwd ^
    --from-file=worker_pwd=%PLAIN%\worker_pwd ^
    --from-file=readonly_pwd=%PLAIN%\readonly_pwd ^
    --dry-run=client -o yaml | kubeseal --format yaml > "%SEALED%"

if errorlevel 1 ( echo kubeseal failed. & exit /b 1 )

echo Secrets sealed to: %SEALED%