#/bin/bash

# Variables
source ./00-variables.sh

# Create the ingress
echo "[$ingressName] ingress does not exist"
echo "Creating [$ingressName] ingress..."
cat $ingressTemplate |
  yq "(.spec.tls[0].hosts[0])|="\""$host"\" |
  yq "(.spec.rules[0].host)|="\""$host"\" |
  kubectl apply -n $namespace -f -