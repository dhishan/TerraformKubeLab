terraform {
  # backend "local" {
  #   path = "../tf_state/aks.tfstate"
  # }
  backend "azurerm" {
    resource_group_name  = "statefiles-store-rg"
    storage_account_name = "statefilesstore"
    container_name       = "cluster"
    key                  = "aks.tfstate"
  }
}

provider "azurerm" {
}

data "terraform_remote_state" "rg" {
  backend = "azurerm"
  config = {
    resource_group_name  = "statefiles-store-rg"
    storage_account_name = "statefilesstore"
    container_name       = "cluster"
    key                  = "rg.tfstate"
  }
}

resource "azurerm_virtual_network" "kubevnet" {
  name                = "${var.aksName}-network"
  resource_group_name      = "${data.terraform_remote_state.rg.outputs.rg_name}"
  location                 = "${data.terraform_remote_state.rg.outputs.rg_location}"
  address_space       = ["10.1.0.0/16","10.144.1.0/24"]
}

resource "azurerm_subnet" "lbsubnet" {
  name                 = "lbsubnet"
  resource_group_name      = "${data.terraform_remote_state.rg.outputs.rg_name}"
  address_prefix       = "10.1.1.0/24"
  virtual_network_name = "${azurerm_virtual_network.kubevnet.name}"

  # # this field is deprecated and will be removed in 2.0 - but is required until then
  # route_table_id = "${azurerm_route_table.example.id}"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name      = "${data.terraform_remote_state.rg.outputs.rg_name}"
  address_prefix       = "10.144.1.0/24"
  virtual_network_name = "${azurerm_virtual_network.kubevnet.name}"

  # # this field is deprecated and will be removed in 2.0 - but is required until then
  # route_table_id = "${azurerm_route_table.example.id}"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.aksName
  location            = "${data.terraform_remote_state.rg.outputs.rg_location}"
  resource_group_name = "${data.terraform_remote_state.rg.outputs.rg_name}"
  dns_prefix          = "${var.aksName}dns"

  agent_pool_profile {
    name            = "default"
    count           = 1
    vm_size         = "Standard_DS2_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"

    vnet_subnet_id = "${azurerm_subnet.internal.id}"
  }
  node_resource_group = "KubeLab-Cluster"
  kubernetes_version  = "1.14.5"

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

  network_profile {
    network_plugin = "azure"
    # service_cidr = "10.144.1.0/24"
    # dns_service_ip = "10.144.1.10"
    # docker_bridge_cidr = "172.17.0.1/16"
  }
}

# https://cloudbuilder.io/documentation/2019-01-28-Azure-Kubernetes-up-and-running-1/
# resource "local_file" "kubeconfig" {
#   content  = "${azurerm_kubernetes_cluster.k8s.kube_config_raw}"
#   filename = "./kubeconfig"
# }

# output "client_certificate" {
#   value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate}"
# }

# output "kube_config" {
#   value = "${azurerm_kubernetes_cluster.k8s.kube_config_raw}"
# }



output "aks_id" {
  value = azurerm_kubernetes_cluster.k8s.id
}

output "aks_rg" {
  value = azurerm_kubernetes_cluster.k8s.node_resource_group
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

output "fqdn" {
  value = azurerm_kubernetes_cluster.k8s.fqdn
}
