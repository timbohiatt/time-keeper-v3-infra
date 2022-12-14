#!/usr/bin/env bash

kubectl delete namespace ops-argocd 
kubectl apply -f namespaces/namespace.yaml
kubectl apply -f install-manifests.yaml || true
kubectl apply -f virtualService.yaml  -n ops-argocd || true