data "azurerm_client_config" "current" {}

locals {
  name_no_hyphens = replace(var.name, "-", "")
}

resource "azurerm_resource_group" "main" {
  name     = "${var.name}-rg"
  location = var.location
}

resource "azurerm_dns_zone" "main" {
  name                = var.dns_zone_domain
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_key_vault" "main" {
  name                       = "${var.name}-kv"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
}

resource "azurerm_role_assignment" "current_user_key_vault_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

import {
  to = azurerm_resource_group.main
  id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.name}-rg"
}

resource "azurerm_storage_account" "main" {
  name                            = "${local.name_no_hyphens}st"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true
  default_to_oauth_authentication = true

  blob_properties {
    versioning_enabled = true
  }
}

import {
  to = azurerm_storage_account.main
  id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.name}-rg/providers/Microsoft.Storage/storageAccounts/${local.name_no_hyphens}st"
}

resource "azurerm_storage_container" "main" {
  name                  = "opentofu"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "private"
}

import {
  to = azurerm_storage_container.main
  id = "${azurerm_storage_account.main.id}/blobServices/default/containers/opentofu"
}

resource "azurerm_role_assignment" "current_sp_storage_blob_data_contributor" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_public_ip" "traefik_ingress" {
  name                = "${var.name}-traefik-pip"
  resource_group_name = azurerm_kubernetes_cluster.main.node_resource_group
  location            = azurerm_kubernetes_cluster.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_container_registry" "main" {
  name                          = "${local.name_no_hyphens}cr"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  sku                           = "Basic"
  admin_enabled                 = false
  anonymous_pull_enabled        = false
  public_network_access_enabled = true
}

resource "azurerm_kubernetes_cluster" "main" {
  name                         = "${var.name}-aks"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  node_resource_group          = "${var.name}-nodes-rg"
  dns_prefix                   = var.name
  sku_tier                     = "Free"
  local_account_disabled       = true
  oidc_issuer_enabled          = true
  workload_identity_enabled    = true
  automatic_upgrade_channel    = "patch"
  node_os_upgrade_channel      = "SecurityPatch"
  image_cleaner_enabled        = true
  image_cleaner_interval_hours = 48

  api_server_access_profile {
    authorized_ip_ranges = var.api_server_authorized_ip_ranges
  }

  default_node_pool {
    name                 = "system"
    auto_scaling_enabled = true
    min_count            = 1
    max_count            = 3
    max_pods             = 250
    vm_size              = "Standard_D2pds_v6"
    os_disk_type         = "Ephemeral"
    os_disk_size_gb      = 30
    os_sku               = "AzureLinux"
    zones                = ["2"]

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
    pod_cidr            = "192.168.0.0/16"
    service_cidr        = "172.16.0.0/16"
    dns_service_ip      = "172.16.0.10"
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    azure_rbac_enabled = true
  }

  maintenance_window {
    allowed {
      day   = "Sunday"
      hours = [2, 3, 4, 5]
    }
  }

  workload_autoscaler_profile {
    vertical_pod_autoscaler_enabled = true
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }
}

resource "azurerm_role_assignment" "aks_kubelet_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

resource "azurerm_kubernetes_cluster_extension" "flux" {
  name           = "flux"
  cluster_id     = azurerm_kubernetes_cluster.main.id
  extension_type = "microsoft.flux"

  configuration_settings = {
    useKubeletIdentity = "true"
  }
}

# NOTE: We intentionally use azapi_resource here because
# azurerm_kubernetes_flux_configuration does not currently expose OCI source
# configuration.
resource "azapi_resource" "flux_configuration" {
  type                      = "Microsoft.KubernetesConfiguration/fluxConfigurations@2025-04-01"
  name                      = "flux-oci"
  parent_id                 = azurerm_kubernetes_cluster.main.id
  schema_validation_enabled = false

  body = {
    properties = {
      scope      = "cluster"
      namespace  = "flux-system"
      sourceKind = "OCIRepository"
      ociRepository = {
        url                   = "oci://${azurerm_container_registry.main.login_server}/flux/platform"
        timeoutInSeconds      = 120
        syncIntervalInSeconds = 60
        useWorkloadIdentity   = true
      }
      kustomizations = {
        platform = {
          path                  = "./"
          syncIntervalInSeconds = 600
          prune                 = true
          postBuild = {
            substitute = {
              TRAEFIK_PIP_NAME           = azurerm_public_ip.traefik_ingress.name
              TRAEFIK_PIP_RESOURCE_GROUP = azurerm_public_ip.traefik_ingress.resource_group_name
              TRAEFIK_LB_IP              = azurerm_public_ip.traefik_ingress.ip_address
              TRAEFIK_ALLOWED_CIDR       = var.api_server_authorized_ip_ranges[0]
            }
          }
        }
      }
    }
  }

  depends_on = [
    azurerm_kubernetes_cluster_extension.flux,
  ]
}

resource "azurerm_role_assignment" "current_user_aks_cluster_admin" {
  scope                = azurerm_kubernetes_cluster.main.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "aks_kv_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_kubernetes_cluster.main.key_vault_secrets_provider[0].secret_identity[0].object_id
}
