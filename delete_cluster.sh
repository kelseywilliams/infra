#!/bin/bash
k3d cluster delete droplet
rm -f overlays/prod/secrets/*.sealed.yaml
