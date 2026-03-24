# Lab 3 exemplar

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.113.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "{your subscription id here}"
}
