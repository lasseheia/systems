terraform {
  required_version = ">= 1.9.0"

  backend "azurerm" {
    resource_group_name  = "${var.name}-rg"
    storage_account_name = "${local.name_no_hyphens}st"
    container_name       = "opentofu"
    key                  = "main.tfstate"
    use_azuread_auth     = true
    use_oidc             = true
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.74.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "2.10.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {}
