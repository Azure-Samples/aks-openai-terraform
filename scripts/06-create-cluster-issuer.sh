#/bin/bash

# Variables
source ./00-variables.sh

# Check if the cluster issuer already exists
result=$(kubectl get ClusterIssuer -o json | jq -r '.items[].metadata.name | select(. == "'$clusterIssuerName'")')

if [[ -n $result ]]; then
  echo "[$clusterIssuerName] cluster issuer already exists"
  exit
else
  # Create the cluster issuer
  echo "[$clusterIssuerName] cluster issuer does not exist"
  echo "Creating [$clusterIssuerName] cluster issuer..."
  cat $clusterIssuerTemplate |
    yq "(.spec.acme.email)|="\""$email"\" |
    kubectl apply -f -
fi
