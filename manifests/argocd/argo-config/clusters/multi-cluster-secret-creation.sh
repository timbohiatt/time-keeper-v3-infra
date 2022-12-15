#!/usr/bin/env bash
PROJECT=$1


PROJECT_NUMBER=$(gcloud projects list --format='csv[no-heading](PROJECT_NUMBER)'  --filter="project_id=${PROJECT}")

for cluster in $(gcloud container clusters list --format='csv[no-heading](name,zone, endpoint)' --filter="name!=automation" --project="${PROJECT}" )
do
    
    echo $cluster

    clusterName=$(echo $cluster | cut -d "," -f 1)
    clusterZone=$(echo $cluster | cut -d "," -f 2)
    clusterEndpoint=$(echo $cluster | cut -d "," -f 3)

    CLUSTER_NAME=$(echo $cluster | cut -d "," -f 1)
    REGION=$(echo $cluster | cut -d "," -f 2)

    gcloud container clusters get-credentials $clusterName --region="$clusterZone" --project="$PROJECT"

    #kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-infra/manifests/istio/namespace.yaml
    #kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-infra/manifests/istio/install-manifests.yaml || true
    #kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-infra/manifests/istio/install-manifests.yaml || true
    #kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-infra/manifests/istio/kiali.yaml || true
    #kubectl apply -f demos/v2-self-managed-multi-region/time-keeper-infra/manifests/istio/prometheus.yaml || true
    #kubectl apply -f demos/v1-self-managed/time-keeper-infra/manifests/istio/jaeger.yaml || true
    #kubectl apply -f demos/v1-self-managed/time-keeper-infra/manifests/istio/zipkin.yaml || true

    cat <<EOF > ${CLUSTER_NAME}-argo-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: ${CLUSTER_NAME}
  labels:
    argocd.argoproj.io/secret-type: cluster
    region: ${REGION}
type: Opaque
stringData:
  name: ${CLUSTER_NAME}
  server: https://connectgateway.googleapis.com/v1beta1/projects/${PROJECT_NUMBER}/locations/global/gkeMemberships/${CLUSTER_NAME}
  config: |
    {
      "execProviderConfig": {
        "command": "argocd-k8s-auth",
        "args": ["gcp"],
        "apiVersion": "client.authentication.k8s.io/v1beta1"
      },
      "tlsClientConfig": {
        "insecure": false,
        "caData": ""
      }
    }
EOF
kubectl apply -f ${CLUSTER_NAME}-argo-secret.yaml
    
done