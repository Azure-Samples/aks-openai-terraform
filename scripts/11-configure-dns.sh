# Variables
source ./00-variables.sh

# Retrieve the public IP address from the ingress
echo "Retrieving the external IP address from the [$ingressName] ingress..."
publicIpAddress=$(kubectl get ingress $ingressName -n $namespace -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -n $publicIpAddress ]; then
  echo "[$publicIpAddress] external IP address of the application gateway ingress controller successfully retrieved from the [$ingressName] ingress"
else
  echo "Failed to retrieve the external IP address of the application gateway ingress controller from the [$ingressName] ingress"
  exit
fi

# Check if an A record for todolist subdomain exists in the DNS Zone
echo "Retrieving the A record for the [$subdomain] subdomain from the [$dnsZoneName] DNS zone..."
ipv4Address=$(az network dns record-set a list \
  --zone-name $dnsZoneName \
  --resource-group $dnsZoneResourceGroupName \
  --query "[?name=='$subdomain'].arecords[].ipv4Address" \
  --output tsv)

if [[ -n $ipv4Address ]]; then
  echo "An A record already exists in [$dnsZoneName] DNS zone for the [$subdomain] subdomain with [$ipv4Address] IP address"

  if [[ $ipv4Address == $publicIpAddress ]]; then
    echo "The [$ipv4Address] ip address of the existing A record is equal to the ip address of the [$ingressName] ingress"
    echo "No additional step is required"
    exit
  else
    echo "The [$ipv4Address] ip address of the existing A record is different than the ip address of the [$ingressName] ingress"
  fi

  # Retrieving name of the record set relative to the zone
  echo "Retrieving the name of the record set relative to the [$dnsZoneName] zone..."

  recordSetName=$(az network dns record-set a list \
    --zone-name $dnsZoneName \
    --resource-group $dnsZoneResourceGroupName \
    --query "[?name=='$subdomain'].name" \
    --output name 2>/dev/null)

  if [[ -n $recordSetName ]]; then
    "[$recordSetName] record set name successfully retrieved"
  else
    "Failed to retrieve the name of the record set relative to the [$dnsZoneName] zone"
    exit
  fi

  # Remove the a record
  echo "Removing the A record from the record set relative to the [$dnsZoneName] zone..."

  az network dns record-set a remove-record \
    --ipv4-address $ipv4Address \
    --record-set-name $recordSetName \
    --zone-name $dnsZoneName \
    --resource-group $dnsZoneResourceGroupName

  if [[ $? == 0 ]]; then
    echo "[$ipv4Address] ip address successfully removed from the [$recordSetName] record set"
  else
    echo "Failed to remove the [$ipv4Address] ip address from the [$recordSetName] record set"
    exit
  fi
fi

# Create the a record
echo "Creating an A record in [$dnsZoneName] DNS zone for the [$subdomain] subdomain with [$publicIpAddress] IP address..."
az network dns record-set a add-record \
  --zone-name $dnsZoneName \
  --resource-group $dnsZoneResourceGroupName \
  --record-set-name $subdomain \
  --ipv4-address $publicIpAddress 1>/dev/null

if [[ $? == 0 ]]; then
  echo "A record for the [$subdomain] subdomain with [$publicIpAddress] IP address successfully created in [$dnsZoneName] DNS zone"
else
  echo "Failed to create an A record for the $subdomain subdomain with [$publicIpAddress] IP address in [$dnsZoneName] DNS zone"
fi
