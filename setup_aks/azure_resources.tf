resource "azurerm_user_assigned_identity" "pods-msi" {
  resource_group_name = "${data.terraform_remote_state.aks.outputs.aks_rg}"
  location            = "${data.terraform_remote_state.aks.outputs.rg_location}"

  name = "${var.aadpod_name}"
}

output "msi_id" {
  value = azurerm_user_assigned_identity.pods-msi.id
}

output "msi_principal_id" {
  value = azurerm_user_assigned_identity.pods-msi.principal_id
}

output "msi_client_id" {
  value = azurerm_user_assigned_identity.pods-msi.client_id
}


resource "azurerm_key_vault" "k8skv" {
  name                        = "k8skv"
  location                    = "${data.terraform_remote_state.aks.outputs.rg_location}"
  resource_group_name         = "${data.terraform_remote_state.aks.outputs.rg_name}"
  enabled_for_disk_encryption = true
  tenant_id                   = var.tenant_id

  sku_name = "standard"

#   access_policy {
#     tenant_id = var.tenant_id
#     object_id = azurerm_user_assigned_identity.pods-msi.principal_id

#     key_permissions = [
#       "decrypt", 
#       "delete", 
#       "encrypt", 
#       "get", 
#       "import", 
#       "list", 
#       "purge", 
#       "recover", 
#       "restore", 
#       "sign", 
#       "unwrapKey", 
#       "update", 
#       "verify", 
#       "wrapKey",
#       "create",
#       "backup"
#     ]

#     secret_permissions = [
#       "get",
#     ]

#     storage_permissions = [
#       "get",
#     ]
#   }

#   network_acls {
#     default_action = "Deny"
#     bypass         = "AzureServices"
#   }
}

resource "azurerm_key_vault_access_policy" "me" {
  key_vault_id = "${azurerm_key_vault.k8skv.id}"

  tenant_id = var.tenant_id
  object_id = "60f26dba-161e-471e-9d83-45d11b1f357a"

  key_permissions = [
      "decrypt", 
      "delete", 
      "encrypt", 
      "get", 
      "import", 
      "list", 
      "purge", 
      "recover", 
      "restore", 
      "sign", 
      "unwrapKey", 
      "update", 
      "verify", 
      "wrapKey",
      "create",
      "backup"
    ]

  secret_permissions = [
    "get",
  ]
}


resource "azurerm_key_vault_access_policy" "msi" {
  key_vault_id = "${azurerm_key_vault.k8skv.id}"

  tenant_id = var.tenant_id
    object_id = azurerm_user_assigned_identity.pods-msi.principal_id

  key_permissions = [
      "decrypt", 
      "delete", 
      "encrypt", 
      "get", 
      "import", 
      "list", 
      "purge", 
      "recover", 
      "restore", 
      "sign", 
      "unwrapKey", 
      "update", 
      "verify", 
      "wrapKey",
      "create",
      "backup"
    ]

  secret_permissions = [
    "get",
  ]
}

resource "azurerm_key_vault_key" "vaultunsealkey" {
  depends_on = [azurerm_key_vault_access_policy.me]
  name         = "${var.vaultunsealkey}"
  key_vault_id = "${azurerm_key_vault.k8skv.id}"
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

resource "azurerm_role_assignment" "kv_reader" {
  scope              = "${data.azurerm_subscription.primary.id}"
  role_definition_name  = "Contributor"
  principal_id       = "${var.SPN_OBJECT_ID}"
}



