@echo off
k3d cluster delete droplet
del /q overlays\local\secrets\*.sealed.yaml
