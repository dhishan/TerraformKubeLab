resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  # api_group has to be empty because of a bug:
  # https://github.com/terraform-providers/terraform-provider-kubernetes/issues/204
  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = "tiller"
    namespace = "kube-system"
  }
}


provider "helm" {
  install_tiller  = true
  service_account = "tiller"
  namespace       = "kube-system"
  kubernetes {
    host     = "${data.terraform_remote_state.aks.outputs.host}"
    # username = "${data.terraform_remote_state.aks.outputs.username}"
    # password = "${data.terraform_remote_state.aks.outputs.password}"

    client_certificate     = "${data.terraform_remote_state.aks.outputs.client_certificate}"
    client_key             = "${data.terraform_remote_state.aks.outputs.client_key}"
    cluster_ca_certificate = "${data.terraform_remote_state.aks.outputs.cluster_ca_certificate}"
  }
}