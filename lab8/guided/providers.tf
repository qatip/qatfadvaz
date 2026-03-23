terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.113.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "bus-unit-state-rg"
    storage_account_name = "butfstate2697"
    container_name       = "tfstate"
    key                  = "bus-unit-state.tfstate"
  }

}

provider "azurerm" {
  features {}
  subscription_id = "911e746f-0030-41d8-839c-c3579ec74ee4"
}
