terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "multi_ip_vm" {
  source = "./modules/multi-ip-vm"

  name                  = var.name
  resource_group_name   = azurerm_resource_group.main.name
  location              = azurerm_resource_group.main.location
  secondary_ip_count    = var.secondary_ip_count
  admin_username        = var.admin_username
  ssh_public_key        = var.ssh_public_key
  vm_size               = var.vm_size
  vnet_address_space    = var.vnet_address_space
  subnet_address_prefix = var.subnet_address_prefix
  private_ip_start      = var.private_ip_start
  tags                  = var.tags
}
