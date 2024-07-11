terraform {
  required_providers {
    azurerm = {
      version = "=3.70.0"
    }
    http = {       
      source  = "hashicorp/http"       
      version = "~> 2.0"     
    }
    
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
provider "http" {   
  # Configuration options if needed 
}