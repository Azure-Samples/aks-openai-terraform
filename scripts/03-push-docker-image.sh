#!/bin/bash

# Variables
source ./00-variables.sh

# Login to ACR
az acr login --name $acrName 

# Retrieve ACR login server. Each container image needs to be tagged with the loginServer name of the registry. 
loginServer=$(az acr show --name $acrName --query loginServer --output tsv)

# Tag the local image with the loginServer of ACR
docker tag ${imageName,,}:$tag $loginServer/${imageName,,}:$tag

# Push latest container image to ACR
docker push $loginServer/${imageName,,}:$tag