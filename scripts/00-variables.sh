# Variables
acrName="CyanAcr"
acrResourceGrougName="CyanRG"
location="FranceCentral"
attachAcr=false
imageName="magic8ball"
tag="v2"
containerName="magic8ball"
image="$acrName.azurecr.io/$imageName:$tag"
imagePullPolicy="IfNotPresent" # Always, Never, IfNotPresent
managedIdentityName="CyanWorkloadManagedIdentity"
federatedIdentityName="Magic8BallFederatedIdentity"

# Azure Subscription and Tenant
subscriptionId=$(az account show --query id --output tsv)
subscriptionName=$(az account show --query name --output tsv)
tenantId=$(az account show --query tenantId --output tsv)

# Parameters
title="Magic 8 Ball"
label="Pose your question and cross your fingers!"
temperature="0.9"
imageWidth="80"

# OpenAI
openAiName="CyanOpenAi "
openAiResourceGroupName="CyanRG"
openAiType="azure_ad"
openAiBase="https://cyanopenai.openai.azure.com/"
openAiModel="gpt-35-turbo"
openAiDeployment="gpt-35-turbo"

# Nginx Ingress Controller
nginxNamespace="ingress-basic"
nginxRepoName="ingress-nginx"
nginxRepoUrl="https://kubernetes.github.io/ingress-nginx"
nginxChartName="ingress-nginx"
nginxReleaseName="nginx-ingress"
nginxReplicaCount=3

# Certificate Manager
cmNamespace="cert-manager"
cmRepoName="jetstack"
cmRepoUrl="https://charts.jetstack.io"
cmChartName="cert-manager"
cmReleaseName="cert-manager"

# Cluster Issuer
email="paolos@microsoft.com"
clusterIssuerName="letsencrypt-nginx"
clusterIssuerTemplate="cluster-issuer.yml"

# AKS Cluster
aksClusterName="CyanAks"
aksResourceGroupName="CyanRG"

# Sample Application
namespace="magic8ball"
serviceAccountName="magic8ball-sa"
deploymentTemplate="deployment.yml"
serviceTemplate="service.yml"
configMapTemplate="configMap.yml"
secretTemplate="secret.yml"

# Ingress and DNS
ingressTemplate="ingress.yml"
ingressName="magic8ball-ingress"
dnsZoneName="contoso.com"
dnsZoneResourceGroupName="DnsResourceGroup"
subdomain="magic"
host="$subdomain.$dnsZoneName"