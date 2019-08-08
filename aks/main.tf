terraform {
  backend "local" {
    path = "../tf_state/aks.tfstate"
  }
}

provider "azurerm" {

}

resource "azurerm_resource_group" "KubeLab" {
  name     = var.rgName
  location = var.location
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.aksName
  location            = var.location
  resource_group_name = "${azurerm_resource_group.KubeLab.name}"
  dns_prefix          = "${var.aksName}-dns"

  agent_pool_profile {
    name            = "default"
    count           = 3
    vm_size         = "Standard_DS2_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"
  }
  node_resource_group = "KubeLab-Cluster"
  kubernetes_version  = "1.13.7"

  service_principal {
    client_id     = "${var.SPN_ID}"
    client_secret = "${var.SPN_SECRET}"
  }

  role_based_access_control {
    enabled = true
  }



  tags = {
    Environment = "Lab"
  }

  # network_profile {
  #   network_plugin = "azure"
  # }
}

# https://cloudbuilder.io/documentation/2019-01-28-Azure-Kubernetes-up-and-running-1/
resource "local_file" "kubeconfig" {
  content  = "${azurerm_kubernetes_cluster.k8s.kube_config_raw}"
  filename = "./kubeconfig"
}

# output "client_certificate" {
#   value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate}"
# }

# output "kube_config" {
#   value = "${azurerm_kubernetes_cluster.k8s.kube_config_raw}"
# }

output "rg_name" {
  value = azurerm_resource_group.KubeLab.name
}

output "rg_location" {
  value = azurerm_resource_group.KubeLab.location
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.k8s.id
}

output "client_certificate" {
  value = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)
}

output "client_key" {
  value = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)
}

output "cluster_ca_certificate" {
  value = base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)
}

output "host" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.host
}
output "username" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.username
}

output "password" {
  value = azurerm_kubernetes_cluster.k8s.kube_config.0.password
}
