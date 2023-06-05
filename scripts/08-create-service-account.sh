#!/bin/bash

# Variables for the user-assigned managed identity
source ./00-variables.sh

# Check if the namespace already exists
result=$(kubectl get namespace -o 'jsonpath={.items[?(@.metadata.name=="'$namespace'")].metadata.name'})

if [[ -n $result ]]; then
  echo "[$namespace] namespace already exists"
else
  # Create the namespace for your ingress resources
  echo "[$namespace] namespace does not exist"
  echo "Creating [$namespace] namespace..."
  kubectl create namespace $namespace
fi

# Check if the service account already exists
result=$(kubectl get sa -n $namespace -o 'jsonpath={.items[?(@.metadata.name=="'$serviceAccountName'")].metadata.name'})

if [[ -n $result ]]; then
  echo "[$serviceAccountName] service account already exists"
else
  # Retrieve the resource id of the user-assigned managed identity
  echo "Retrieving clientId for [$managedIdentityName] managed identity..."
  managedIdentityClientId=$(az identity show \
    --name $managedIdentityName \
    --resource-group $aksResourceGroupName \
    --query clientId \
    --output tsv)

  if [[ -n $managedIdentityClientId ]]; then
    echo "[$managedIdentityClientId] clientId  for the [$managedIdentityName] managed identity successfully retrieved"
  else
    echo "Failed to retrieve clientId for the [$managedIdentityName] managed identity"
    exit
  fi

  # Create the service account
  echo "[$serviceAccountName] service account does not exist"
  echo "Creating [$serviceAccountName] service account..."
  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: $managedIdentityClientId
    azure.workload.identity/tenant-id: $tenantId
  labels:
    azure.workload.identity/use: "true"
  name: $serviceAccountName
  namespace: $namespace
EOF
fi

# Show service account YAML manifest
echo "Service Account YAML manifest"
echo "-----------------------------"
kubectl get sa $serviceAccountName -n $namespace -o yaml

# Check if the federated identity credential already exists
echo "Checking if [$federatedIdentityName] federated identity credential actually exists in the [$aksResourceGroupName] resource group..."

az identity federated-credential show \
  --name $federatedIdentityName \
  --resource-group $aksResourceGroupName \
  --identity-name $managedIdentityName &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$federatedIdentityName] federated identity credential actually exists in the [$aksResourceGroupName] resource group"

  # Get the OIDC Issuer URL
  aksOidcIssuerUrl="$(az aks show \
    --only-show-errors \
    --name $aksClusterName \
    --resource-group $aksResourceGroupName \
    --query oidcIssuerProfile.issuerUrl \
    --output tsv)"

  # Show OIDC Issuer URL
  if [[ -n $aksOidcIssuerUrl ]]; then
    echo "The OIDC Issuer URL of the $aksClusterName cluster is $aksOidcIssuerUrl"
  fi

  echo "Creating [$federatedIdentityName] federated identity credential in the [$aksResourceGroupName] resource group..."

  # Establish the federated identity credential between the managed identity, the service account issuer, and the subject.
  az identity federated-credential create \
    --name $federatedIdentityName \
    --identity-name $managedIdentityName \
    --resource-group $aksResourceGroupName \
    --issuer $aksOidcIssuerUrl \
    --subject system:serviceaccount:$namespace:$serviceAccountName

  if [[ $? == 0 ]]; then
    echo "[$federatedIdentityName] federated identity credential successfully created in the [$aksResourceGroupName] resource group"
  else
    echo "Failed to create [$federatedIdentityName] federated identity credential in the [$aksResourceGroupName] resource group"
    exit
  fi
else
  echo "[$federatedIdentityName] federated identity credential already exists in the [$aksResourceGroupName] resource group"
fi