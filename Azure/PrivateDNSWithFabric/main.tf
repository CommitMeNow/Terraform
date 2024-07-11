#******EXAMPLE NOTES**************************************************
#This sample code deploys a private DNS and a single Microsoft Fabric Resource.
#The private DNS is this updated with the GUID ID of the Fabric resource.
#
#NOTE:  This will NOT scale for more than one Fabric Resource. Looping code must be implemented to support this. 
#
###############################################################
#*********************************************************************
#Deployment resource group for all resources
resource "azurerm_resource_group" "rg-deployment" {
  name     = var.rgName
  location = var.location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet-01" {
  name                = "vnet-01"
  resource_group_name = azurerm_resource_group.rg-deployment.name
  location            = azurerm_resource_group.rg-deployment.location
  address_space       = ["10.40.0.0/20"]
}
#Create the first subnet
resource "azurerm_subnet" "snet-0"{
    name = "snet-0"
    resource_group_name = azurerm_resource_group.rg-deployment.name
    virtual_network_name = azurerm_virtual_network.vnet-01.name
    address_prefixes = ["10.40.0.0/24"]

}

#Create the private DNS zone
resource "azurerm_private_dns_zone" "privateZone01" {
  resource_group_name = azurerm_resource_group.rg-deployment.name
  name = "adventureworks.org"
}

#Connect DNS zone to the virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "vnet-01-link"
  resource_group_name = azurerm_resource_group.rg-deployment.name
  private_dns_zone_name = azurerm_private_dns_zone.privateZone01.name
  virtual_network_id    = azurerm_virtual_network.vnet-01.id
  registration_enabled = true #enable automatic registration for VMs
}


//**************************************************************************

#createa a capacity F2
module "fabric-capacityF2" {
  source            = "github.com/Azure/azure-data-labs-modules/terraform/fabric/fabric-capacity"
  resource_group_id = azurerm_resource_group.rg-deployment.id
  location          = var.location

  basename          = var.myF2capacityname
  sku               = var.sku
  admin_email       = var.admin_email

}

#http GET for capactities in my subscription
data "http" "getAllMyCapacities" {
  url = "https://api.fabric.microsoft.com/v1/capacities"
  
  //************************************************************************
  //When testing as yourself, just run this to get a token and replace the string below:
  //az account get-access-token --resource https://api.fabric.microsoft.com
  //*************************************************************************
  request_headers = {
    Authorization = "Bearer COPYTOKENHERE"
  }
  depends_on = [ module.fabric-capacityF2 ]
}

#Insert the Private DNS record
resource "azurerm_private_dns_cname_record" "myF2cnamerecord" {
  name                = var.myF2capacityname
  zone_name           = azurerm_private_dns_zone.privateZone01.name
  resource_group_name = azurerm_resource_group.rg-deployment.name
  ttl                 = 300
  record              = "${jsondecode(data.http.getAllMyCapacities.response_body).value[0].id}.fabric.core.windows.net"
} 



