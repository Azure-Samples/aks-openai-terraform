#!/bin/bash

# Variables
source ./00-variables.sh

# Check if the user-assigned managed identity already exists
echo "Checking if [$managedIdentityName] user-assigned managed identity actually exists in the [$aksResourceGroupName] resource group..."

az identity show \
  --name $managedIdentityName \
  --resource-group $aksResourceGroupName &>/dev/null

if [[ $? != 0 ]]; then
  echo "No [$managedIdentityName] user-assigned managed identity actually exists in the [$aksResourceGroupName] resource group"
  echo "Creating [$managedIdentityName] user-assigned managed identity in the [$aksResourceGroupName] resource group..."

  # Create the user-assigned managed identity
  az identity create \
    --name $managedIdentityName \
    --resource-group $aksResourceGroupName \
    --location $location \
    --subscription $subscriptionId 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$managedIdentityName] user-assigned managed identity successfully created in the [$aksResourceGroupName] resource group"
  else
    echo "Failed to create [$managedIdentityName] user-assigned managed identity in the [$aksResourceGroupName] resource group"
    exit
  fi
else
  echo "[$managedIdentityName] user-assigned managed identity already exists in the [$aksResourceGroupName] resource group"
fi

# Retrieve the clientId of the user-assigned managed identity
echo "Retrieving clientId for [$managedIdentityName] managed identity..."
clientId=$(az identity show \
  --name $managedIdentityName \
  --resource-group $aksResourceGroupName \
  --query clientId \
  --output tsv)

if [[ -n $clientId ]]; then
  echo "[$clientId] clientId  for the [$managedIdentityName] managed identity successfully retrieved"
else
  echo "Failed to retrieve clientId for the [$managedIdentityName] managed identity"
  exit
fi

# Retrieve the principalId of the user-assigned managed identity
echo "Retrieving principalId for [$managedIdentityName] managed identity..."
principalId=$(az identity show \
  --name $managedIdentityName \
  --resource-group $aksResourceGroupName \
  --query principalId \
  --output tsv)

if [[ -n $principalId ]]; then
  echo "[$principalId] principalId  for the [$managedIdentityName] managed identity successfully retrieved"
else
  echo "Failed to retrieve principalId for the [$managedIdentityName] managed identity"
  exit
fi

# Get the resource id of the Azure OpenAI resource
openAiId=$(az cognitiveservices account show \
  --name $openAiName \
  --resource-group $openAiResourceGroupName \
  --query id \
  --output tsv)

if [[ -n $openAiId ]]; then
  echo "Resource id for the [$openAiName] Azure OpenAI resource successfully retrieved"
else
  echo "Failed to the resource id for the [$openAiName] Azure OpenAI resource"
  exit -1
fi

# Assign the Cognitive Services User role on the Azure OpenAI resource to the managed identity
role="Cognitive Services User"
echo "Checking if the [$managedIdentityName] managed identity has been assigned to [$role] role with [$openAiName] Azure OpenAI resource as a scope..."
current=$(az role assignment list \
  --assignee $principalId \
  --scope $openAiId \
  --query "[?roleDefinitionName=='$role'].roleDefinitionName" \
  --output tsv 2>/dev/null)

if [[ $current == $role ]]; then
  echo "[$managedIdentityName] managed identity is already assigned to the ["$current"] role with [$openAiName] Azure OpenAI resource as a scope"
else
  echo "[$managedIdentityName] managed identity is not assigned to the [$role] role with [$openAiName] Azure OpenAI resource as a scope"
  echo "Assigning the [$role] role to the [$managedIdentityName] managed identity with [$openAiName] Azure OpenAI resource as a scope..."

  az role assignment create \
    --assignee $principalId \
    --role "$role" \
    --scope $openAiId 1>/dev/null

  if [[ $? == 0 ]]; then
    echo "[$managedIdentityName] managed identity successfully assigned to the [$role] role with [$openAiName] Azure OpenAI resource as a scope"
  else
    echo "Failed to assign the [$managedIdentityName] managed identity to the [$role] role with [$openAiName] Azure OpenAI resource as a scope"
    exit
  fi
fi