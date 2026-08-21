#!/bin/bash

# Variables
source ./00-variables.sh

# Attach ACR to AKS cluster
if [[ $attachAcr == true ]]; then
  echo "Attaching ACR $acrName to AKS cluster $aksClusterName..."
  az aks update \
    --name $aksClusterName \
    --resource-group $aksResourceGroupName \
    --attach-acr $acrName
fi

# Check if namespace exists in the cluster
result=$(kubectl get namespace -o jsonpath="{.items[?(@.metadata.name=='$namespace')].metadata.name}")

if [[ -n $result ]]; then
  echo "$namespace namespace already exists in the cluster"
else
  echo "$namespace namespace does not exist in the cluster"
  echo "creating $namespace namespace in the cluster..."
  kubectl create namespace $namespace
fi

# Create secret
if [[ -z $appPasswordHash ]]; then
  if [[ -z $appPassword ]]; then
    echo "Set APP_PASSWORD or APP_PASSWORD_HASH before deploying the sample application."
    exit 1
  fi

  appPasswordHash=$(APP_PASSWORD="$appPassword" python3 - <<'PY'
import base64
import hashlib
import os

password = os.environ["APP_PASSWORD"].encode("utf-8")
salt = os.urandom(16)
iterations = 260000
key = hashlib.pbkdf2_hmac("sha256", password, salt, iterations)
print(f"pbkdf2_sha256${iterations}${base64.b64encode(salt).decode()}${base64.b64encode(key).decode()}")
PY
)
fi

if [[ $openAiType == "azure" && -z $openAiKey ]]; then
  echo "Set AZURE_OPENAI_KEY when openAiType is azure."
  exit 1
fi

kubectl create secret generic magic8ball-secret \
  --from-literal=APP_PASSWORD_HASH="$appPasswordHash" \
  --from-literal=AZURE_OPENAI_KEY="$openAiKey" \
  --dry-run=client \
  -o yaml |
  kubectl apply -n $namespace -f -

# Create config map
cat $configMapTemplate |
    yq "(.data.TITLE)|="\""$title"\" |
    yq "(.data.LABEL)|="\""$label"\" |
    yq "(.data.TEMPERATURE)|="\""$temperature"\" |
    yq "(.data.IMAGE_WIDTH)|="\""$imageWidth"\" |
    yq "(.data.AZURE_OPENAI_TYPE)|="\""$openAiType"\" |
    yq "(.data.AZURE_OPENAI_BASE)|="\""$openAiBase"\" |
    yq "(.data.AZURE_OPENAI_MODEL)|="\""$openAiModel"\" |
    yq "(.data.AZURE_OPENAI_DEPLOYMENT)|="\""$openAiDeployment"\" |
    kubectl apply -n $namespace -f -

# Create deployment
cat $deploymentTemplate |
    yq "(.spec.template.spec.containers[0].image)|="\""$image"\" |
    yq "(.spec.template.spec.containers[0].imagePullPolicy)|="\""$imagePullPolicy"\" |
    yq "(.spec.template.spec.serviceAccountName)|="\""$serviceAccountName"\" |
    kubectl apply -n $namespace -f -

# Create deployment
kubectl apply -f $serviceTemplate -n $namespace