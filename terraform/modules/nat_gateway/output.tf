output "name" {
  value = azurerm_nat_gateway.nat_gateway.name
  description = "Specifies the name of the Azure NAT Gateway"
}

output "id" {
  value = azurerm_nat_gateway.nat_gateway.id
  description = "Specifies the resource id of the Azure NAT Gateway"
}

output "public_ip_address" {
  value = azurerm_public_ip.nat_gategay_public_ip.ip_address
  description = "Contains the public IP address of the Azure NAT Gateway."
}