terraform {
  # backend "local" {
  #   path = "../tf_state/app.tfstate"
  # }
  backend "azurerm" {
    resource_group_name  = "statefiles-store-rg"
    storage_account_name = "statefilesstore"
    container_name       = "cluster"
    key                  = "kube.tfstate"
  }
}

data "terraform_remote_state" "aks" {
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