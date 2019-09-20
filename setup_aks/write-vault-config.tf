data "template_file" "vault_extras_config" {
  template = "${file("./vaultextrastemplate.yaml")}"
  vars = {
    client_id = azurerm_user_assigned_identity.pods-msi.client_id
  }
}

resource "null_resource" "vault_extras_config_write" {
  provisioner "local-exec" {
    command = "echo ${data.template_file.vault_extras_config.rendered} > ../extras.yaml"
  }
}