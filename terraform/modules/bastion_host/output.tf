output "name" {
  depends_on = [azurerm_bastion_host.bastion_host]
  value = azurerm_bastion_host.bastion_host.*.name
  description = "Specifies the name of the bastion host"
}

output "id" {
  depends_on = [azurerm_bastion_host.bastion_host]
  value = azurerm_bastion_host.bastion_host.*.id
  description = "Specifies the resource id of the bastion host"
}

output "bastion_host" {
  depends_on = [azurerm_bastion_host.bastion_host]
  value = azurerm_bastion_host.bastion_host
  description = "Contains the bastion host resource"
}

output "public_ip_address" {
  depends_on = [azurerm_bastion_host.bastion_host]
  value = azurerm_public_ip.public_ip.ip_address
  description = "Contains the public IP address of the bastion host."
}