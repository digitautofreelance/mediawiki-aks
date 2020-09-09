provider "azurerm" {
    version = "~>2.0"
    features {}
}

module "cluster" {
    source = "./modules/clusters"
    location = var.location
    admin_username = var.admin_username
    ssh_key = var.ssh_key
    client_id = var.client_id
    client_secret = var.client_secret
}