provider "azurerm" {
    version = "=2.5.0"
    
    subscription_id = var.subscription_id
    client_id       = var.serviceprinciple_id
    client_secret   = var.serviceprinciple_key
    tenant_id       = var.tenant_id

    features {}
}

module "cluster" {
    source = "./modules/clusters"
    serviceprinciple_id   = var.serviceprinciple_id
    serviceprinciple_key  = var.serviceprinciple_key
    location = var.location
    admin_username = var.admin_username
    ssh_key = var.ssh_key
    kubernetes_version = var.kubernetes_version
}
