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
    storage_account_name = "advtfstate26971"
    container_name       = "tfstate"
    key                  = "prod.tfstate"
  }

}

provider "azurerm" {
  features {}
  subscription_id = "6e30168d-855b-47ca-a11c-757b815c1bbe"
}
