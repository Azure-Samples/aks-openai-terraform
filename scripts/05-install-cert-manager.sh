#/bin/bash

# Variables
source ./00-variables.sh

# Check if the ingress-nginx repository is not already added
result=$(helm repo list | grep $cmRepoName | awk '{print $1}')

if [[ -n $result ]]; then
  echo "[$cmRepoName] Helm repo already exists"
else
  # Add the Jetstack Helm repository
  echo "Adding [$cmRepoName] Helm repo..."
  helm repo add $cmRepoName $cmRepoUrl
fi

# Update your local Helm chart repository cache
echo 'Updating Helm repos...'
helm repo update

# Install cert-manager Helm chart
result=$(helm list -n $cmNamespace | grep $cmReleaseName | awk '{print $1}')

if [[ -n $result ]]; then
  echo "[$cmReleaseName] cert-manager already exists in the $cmNamespace namespace"
else
  # Install the cert-manager Helm chart
  echo "Deploying [$cmReleaseName] cert-manager to the $cmNamespace namespace..."
  helm install $cmReleaseName $cmRepoName/$cmChartName \
    --create-namespace \
    --namespace $cmNamespace \
    --set installCRDs=true \
    --set nodeSelector."kubernetes\.io/os"=linux
fi
