

provider "kubernetes" {
  host     = "${data.terraform_remote_state.aks.outputs.host}"
  # username = "${data.terraform_remote_state.aks.outputs.username}"
  # password = "${data.terraform_remote_state.aks.outputs.password}"

  client_certificate     = "${data.terraform_remote_state.aks.outputs.client_certificate}"
  client_key             = "${data.terraform_remote_state.aks.outputs.client_key}"
  cluster_ca_certificate = "${data.terraform_remote_state.aks.outputs.cluster_ca_certificate}"
}


# Network Contributor for the SPN
data "azurerm_subscription" "primary" {}

resource "azurerm_role_assignment" "spn_network_contributor" {
  scope              = "${data.azurerm_subscription.primary.id}"
  role_definition_name  = "Contributor"
  principal_id       = "${var.SPN_OBJECT_ID}"
}


