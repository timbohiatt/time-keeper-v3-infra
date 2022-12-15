#!/usr/bin/env bash
export PROJECT=$1

for cluster in $(gcloud container clusters list --format='csv[no-heading](name,zone,endpoint)' --project $PROJECT)
do
	
clusterName=$(echo $cluster | cut -d "," -f 1)
clusterZone=$(echo $cluster | cut -d "," -f 2)
clusterEndpoint=$(echo $cluster | cut -d "," -f 3)
clusterCACert=$(gcloud container clusters describe $clusterName --region $clusterZone --format='csv[no-heading](masterAuth.clusterCaCertificate)' | base64)

echo $cluster
echo $clusterName
echo $clusterZone
echo $clusterEndpoint

cat <<EOF > ${clusterName}-argo-secret.yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: ${clusterName}
  labels:
    argocd.argoproj.io/secret-type: cluster
    region: ${clusterZone}
type: Opaque
stringData:
  name: ${clusterName}
  server: https://${clusterEndpoint}
  config: |
	{
      "execProviderConfig": {
        "command": "argocd-k8s-auth",
        "args": ["gcp"],
        "apiVersion": "client.authentication.k8s.io/v1beta1"
      },
 	"tlsClientConfig": {
        "insecure": false,
        "caData": ${clusterCACert}
      }
EOF

kubectl apply -f ${clusterName}-argo-secret.yaml -n argocd
done