# Create AADPodIdentity Daemonset

# data "local_file" "daemonset" {
#     filename = "${path.module}/podidentity-daemonset.yaml"
# }
# The HOST_IP Variable is not processed as the $ is causing problems
# resource "null_resource" "podidentity_daemonset" {
#   provisioner "local-exec" {
#     command = "cat <<EOF | kubectl apply -f -\n${data.local_file.daemonset.content}\nEOF"
#   }
# }

resource "null_resource" "podidentity_daemonset_cmd" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/podidentity-daemonset.yaml"
  }
}


# Create AzureIdentity Resource
data "template_file" "aadpod_identity_resource" {
  template = "${file("./aadpodidentity_template.yaml")}"
  vars = {
    aad_id_name = var.aadpod_name
    pods_resource_id = azurerm_user_assigned_identity.pods-msi.id
    pods_client_id = azurerm_user_assigned_identity.pods-msi.client_id
    label = "app"
  }
}

resource "null_resource" "create_podIdentity" {
  depends_on = [null_resource.podidentity_daemonset_cmd]
  provisioner "local-exec" {
    command = "cat <<EOF | kubectl apply -f -\n${data.template_file.aadpod_identity_resource.rendered}\nEOF"
  }
}