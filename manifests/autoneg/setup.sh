#!/usr/bin/env bash

kubectl delete namespace autoneg-system
kubectl apply -f install-manifests.yaml || true
