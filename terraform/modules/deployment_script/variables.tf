variable "resource_group_name" {
  description = "(Required) Specifies the resource group name"
  type = string
}

variable "location" {
  description = "(Required) Specifies the location of the Azure OpenAI Service"
  type = string
}

variable "name" {
  description = "(Required) Specifies the name of the Azure OpenAI Service"
  type = string
  default = "BashScript"
}

variable "azure_cli_version" {
  description = "(Required) Azure CLI module version to be used."
  type = string
  default = "2.9.1"
}

variable "managed_identity_name" {
  description = "Specifies the name of the user-defined managed identity used by the deployment script."
  type = string
  default = "ScriptManagedIdentity"
}

variable "primary_script_uri" {
  description = "(Optional) Uri for the script. This is the entry point for the external script. Changing this forces a new Resource Deployment Script to be created."
  type = string
}

variable "aks_cluster_name" {
  description = "Specifies the name of the AKS cluster."
  type = string
}

variable "tenant_id" {
  description = "Specifies the Azure AD tenant id."
  type = string
}

variable "subscription_id" {
  description = "Specifies the Azure subscription id."
  type = string
}

variable "hostname" {
  description = "Specifies the hostname of the application."
  type = string
}

variable "namespace" {
  description = "Specifies the namespace of the application."
  type = string
}

variable "service_account_name" {
  description = "Specifies the service account of the application."
  type = string
}

variable "workload_managed_identity_client_id" {
  description = "Specifies the client id of the workload user-defined managed identity."
  type = string
}

variable "email" {
  description = "Specifies the email address for the cert-manager cluster issuer."
  type = string
}

variable "tags" {
  description = "(Optional) Specifies the tags of the Azure OpenAI Service"
  type        = map(any)
  default     = {}
}