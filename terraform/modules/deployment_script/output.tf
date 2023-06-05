output "id" {
  value = azurerm_resource_deployment_script_azure_cli.script.id
  description = "Specifies the resource id of the deployment script"
}

output "outputs" {
  value = azurerm_resource_deployment_script_azure_cli.script.outputs
  description = "Specifies the list of script outputs."
}