terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.113.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "landing-zone-shared-tfstate-rg"
    storage_account_name = "advtfstate{suffix}"
    container_name       = "tfstate"
    key                  = "dev.tfstate"
  }

}

provider "azurerm" {
  features {}
  subscription_id = "{your subscription id here}"
}
