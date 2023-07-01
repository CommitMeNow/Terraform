terraform {
  required_version = ">=1.5.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.62.0"
    }
  }
}
provider "azurerm" {
  features {}
}
