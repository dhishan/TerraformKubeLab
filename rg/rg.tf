variable "location" {
    default = "eastus2"
}
variable "rgName" {}

terraform {
  # backend "local" {
  #   path = "../tf_state/aks.tfstate"
  # }
  backend "azurerm" {
    resource_group_name  = "statefiles-store-rg"
    storage_account_name = "statefilesstore"
    container_name       = "cluster"
    key                  = "rg.tfstate"
  }
}

provider "azurerm" {

}

resource "azurerm_resource_group" "KubeLab" {
  name     = var.rgName
  location = var.location
}

output "rg_name" {
  value = azurerm_resource_group.KubeLab.name
}

output "rg_location" {
  value = azurerm_resource_group.KubeLab.location
}