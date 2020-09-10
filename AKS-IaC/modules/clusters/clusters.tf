resource "azurerm_resource_group" "aks-learning" {
    name ="aks-learning"
    location = var.location
}

resource "azurerm_kubernetes_cluster" "aks-learning-cka" {
    name                   = "aks-learning-cka"
    location               = azurerm_resource_group.aks-learning.location
    resource_group_name    = azurerm_resource_group.aks-learning.name
    dns_prefix             = "aks-learning"
    kubernetes_version     = var.kubernetes_version

# Adding default node pool
    default_node_pool {
        name        = "default"
        node_count  =  1
        vm_size     = "Standard_B2s"
        type        = "VirtualMachineScaleSets"
        os_disk_size_gb = 35
    }
# Providing service principal account to interact with AKS
   service_principal {
       client_id = var.serviceprinciple_id
       client_secret = var.serviceprinciple_key
   }
# Adding the linux profile to access the nodes from the node pool
   linux_profile {
    admin_username = var.admin_username
    ssh_key {
       key_data = file(var.ssh_key)
    }
  }
# Adding the network profile
   network_profile {
       network_plugin = "kubenet"
       load_balancer_sku = "Standard"
   }
# Adding the addons to the profile
   addon_profile {
       aci_connector_linux {
           enabled= false
       }
       azure_policy {
           enabled= false
       }
       http_application_routing {
        enabled = false
      }
       kube_dashboard {
           enabled= false
       }
       oms_agent {
           enabled= false
       }
   }
}
