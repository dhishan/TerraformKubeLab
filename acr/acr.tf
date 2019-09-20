terraform {
  # backend "local" {
  #   path = "../tf_state/acr.tfstate"
  # }
  backend "azurerm" {
    resource_group_name  = "statefiles-store-rg"
    storage_account_name = "statefilesstore"
    container_name       = "cluster"
    key                  = "acr.tfstate"
  }
}

provider "azurerm" { 
}

data "terraform_remote_state" "rg" {
  # backend = "local"

  # config = {
  #   path = "${path.module}/../tf_state/aks.tfstate"
  # }
  backend = "azurerm"
  config = {
    resource_group_name  = "statefiles-store-rg"
    storage_account_name = "statefilesstore"
    container_name       = "cluster"
    key                  = "aks.tfstate"
  }
}

resource "azurerm_container_registry" "acr" {
  name                     = "containerRegistryLabDhishan"
  resource_group_name      = "${data.terraform_remote_state.rg.outputs.rg_name}"
  location                 = "${data.terraform_remote_state.rg.outputs.rg_location}"
  sku                      = "Standard"
  admin_enabled            = true
}

resource "azurerm_role_assignment" "acrpullrole" {
  scope = data.terraform_remote_state.rg.outputs.aks_id
  role_definition_name = "AcrPull"
  principal_id = var.SPN_OBJECT_ID
}