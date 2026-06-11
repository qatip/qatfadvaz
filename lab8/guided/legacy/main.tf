terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "{your subscription id here}"
}


locals {
  rg_name     = "legacy-rg"
  vnet_name   = "legacy-vnet"
  subnet_name = "legacy-subnet"
  nic_name    = "legacy-nic"
  location    = "UK South"
}

resource "azurerm_resource_group" "legacy" {
  name     = local.rg_name
  location = local.location
}

resource "azurerm_virtual_network" "legacy" {
  name                = local.vnet_name
  location            = azurerm_resource_group.legacy.location
  resource_group_name = azurerm_resource_group.legacy.name
  address_space       = ["10.90.0.0/16"]
}

resource "azurerm_subnet" "legacy" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.legacy.name
  virtual_network_name = azurerm_virtual_network.legacy.name
  address_prefixes     = ["10.90.1.0/24"]
}

resource "azurerm_network_interface" "legacy" {
  name                = local.nic_name
  location            = azurerm_resource_group.legacy.location
  resource_group_name = azurerm_resource_group.legacy.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.legacy.id
    private_ip_address_allocation = "Dynamic"
  }
}

output "legacy_resource_group_name" {
  value       = azurerm_resource_group.legacy.name
  description = "Legacy resource group name."
}

output "legacy_vnet_id" {
  value       = azurerm_virtual_network.legacy.id
  description = "Legacy VNet resource ID."
}

output "legacy_subnet_id" {
  value       = azurerm_subnet.legacy.id
  description = "Legacy subnet resource ID."
}

output "legacy_nic_id" {
  value       = azurerm_network_interface.legacy.id
  description = "Legacy NIC resource ID."
}

