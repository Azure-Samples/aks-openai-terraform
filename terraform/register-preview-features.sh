#!/bin/bash

# Install aks-preview Azure extension
echo "Checking if [aks-preview] extension is already installed..."
az extension show --name aks-preview &>/dev/null

if [[ $? == 0 ]]; then
  echo "[aks-preview] extension is already installed"
  
  # Update the extension to make sure you have the latest version installed
  echo "Updating [aks-preview] extension..."
  az extension update --name aks-preview &>/dev/null
else
  echo "[aks-preview] extension is not installed. Installing..."
  
  # Install aks-preview extension
  az extension add --name aks-preview 1>/dev/null
  
  if [[ $? == 0 ]]; then
    echo "[aks-preview] extension successfully installed"
  else
    echo "Failed to install [aks-preview] extension"
    exit
  fi
fi

# Registering AKS features
aksExtensions=(
  "AzureServiceMeshPreview"
  "AKS-KedaPreview"
  "RunCommandPreview"
  "EnableOIDCIssuerPreview"
  "EnableWorkloadIdentityPreview"
  "EnableImageCleanerPreview"
"AKS-VPAPreview")
ok=0
registeringExtensions=()
for aksExtension in ${aksExtensions[@]}; do
  echo "Checking if [$aksExtension] extension is already registered..."
  extension=$(az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/$aksExtension') && @.properties.state == 'Registered'].{Name:name}" --output tsv)
  if [[ -z $extension ]]; then
    echo "[$aksExtension] extension is not registered."
    echo "Registering [$aksExtension] extension..."
    az feature register --name $aksExtension --namespace Microsoft.ContainerService
    registeringExtensions+=("$aksExtension")
    ok=1
  else
    echo "[$aksExtension] extension is already registered."
  fi
done
echo $registeringExtensions
delay=1
for aksExtension in ${registeringExtensions[@]}; do
  echo -n "Checking if [$aksExtension] extension is already registered..."
  while true; do
    extension=$(az feature list -o table --query "[?contains(name, 'Microsoft.ContainerService/$aksExtension') && @.properties.state == 'Registered'].{Name:name}" --output tsv)
    if [[ -z $extension ]]; then
      echo -n "."
      sleep $delay
    else
      echo "."
      break
    fi
  done
done

if [[ $ok == 1 ]]; then
  echo "Refreshing the registration of the Microsoft.ContainerService resource provider..."
  az provider register --namespace Microsoft.ContainerService
  echo "Microsoft.ContainerService resource provider registration successfully refreshed"
fi