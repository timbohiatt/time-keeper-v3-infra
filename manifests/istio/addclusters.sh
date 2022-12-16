#!/usr/bin/env bash
export PROJECT=$1
export SA=$2

for cluster in $(gcloud container clusters list --format='csv[no-heading](name,zone,endpoint)' --project $PROJECT)
do
	
clusterName=$(echo $cluster | cut -d "," -f 1)
clusterZone=$(echo $cluster | cut -d "," -f 2)
clusterEndpoint=$(echo $cluster | cut -d "," -f 3)
clusterCACert=$(gcloud container clusters describe $clusterName --region $clusterZone --format='csv[no-heading](masterAuth.clusterCaCertificate)')

echo $cluster
echo $clusterName
echo $clusterZone
echo $clusterEndpoint


if [ $clusterName != "automation" ]; then


gcloud container clusters get-credentials $clusterName --region $clusterZone
kubectl apply -f manifests/istio/namespace.yaml
kubectl apply -f manifests/istio/install-manifests.yaml
kubectl apply -f manifests/istio/plugins/jaeger --recursive
kubectl apply -f manifests/istio/plugins/kiali --recursive
kubectl apply -f manifests/istio/plugins/prometheus --recursive

fi
done

