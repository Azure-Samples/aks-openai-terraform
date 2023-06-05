resource "azurerm_user_assigned_identity" "script_identity" {
  name                = var.managed_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

data "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.aks_cluster_name
  resource_group_name = var.resource_group_name  
}

resource "azurerm_role_assignment" "network_contributor_assignment" {
  scope                = data.azurerm_kubernetes_cluster.aks_cluster.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = azurerm_user_assigned_identity.script_identity.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_resource_deployment_script_azure_cli" "script" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = var.azure_cli_version
  retention_interval  = "P1D"
  command_line        = "'foo' 'bar'"
  cleanup_preference  = "OnSuccess"
  force_update_tag    = "1"
  timeout             = "PT30M"
  primary_script_uri  = var.primary_script_uri
  tags                = var.tags

  identity {
    type = "UserAssigned"
    identity_ids      = [
      azurerm_user_assigned_identity.script_identity.id
    ]
  }

  environment_variable {
    name              = "clusterName"
    value             = var.aks_cluster_name
  }

  environment_variable {
    name              = "resourceGroupName"
    value             = var.resource_group_name
  }

  environment_variable {
    name              = "applicationGatewayEnabled"
    value             = false
  }

  environment_variable {
    name              = "tenantId"
    value             = var.tenant_id
  }

  environment_variable {
    name              = "subscriptionId"
    value             = var.subscription_id
  }

  environment_variable {
    name              = "hostName"
    value             = var.hostname
  }

  environment_variable {
    name              = "namespace"
    value             = var.namespace
  }

  environment_variable {
    name              = "serviceAccountName"
    value             = var.service_account_name
  }

  environment_variable {
    name              = "workloadManagedIdentityClientId"
    value             = var.workload_managed_identity_client_id
  }

  environment_variable {
    name              = "email"
    value             = var.email
  }
}