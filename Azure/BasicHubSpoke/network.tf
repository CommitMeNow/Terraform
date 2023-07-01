
#Hub Vnet
resource "azurerm_virtual_network" "vnet-hub" {
  name                = "vnet-hub"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

#Hub Subnet
resource "azurerm_subnet" "hub-subnet" {
  name                 = "snet-hub"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet-hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

#Spoke A Vnet
resource "azurerm_virtual_network" "spokeA-vnet" {
  name                = "vnet-spokeA"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.10.0.0/16"]
}

#Spoke A Subnet 01
resource "azurerm_subnet" "spokeA-subnet" {
  name                 = "snet-SpokeA-01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spokeA-vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

#Spoke B Vnet
resource "azurerm_virtual_network" "spokeB-vnet" {
  name                = "vnet-spokeB"
  location            = "westus"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.11.0.0/16"]
}

#Spoke B Subnet 01
resource "azurerm_subnet" "spokeB-subnet" {
  name                 = "snet-SpokeB-01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spokeB-vnet.name
  address_prefixes     = ["10.11.1.0/24"]
}

#Peering Spoke A to Hub
#Note these are in the same region
resource "azurerm_virtual_network_peering" "peerSpokeAToHub" {
  name                         = "peering-spokeA-Hub"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.spokeA-vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet-hub.id
  allow_virtual_network_access = true
}
#Peering Hub to Spoke A 
#Note these are in the same region
resource "azurerm_virtual_network_peering" "peerHubToSpokeA" {
  name                         = "peering-hub-SpokeA"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnet-hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spokeA-vnet.id
  allow_virtual_network_access = true
}

#Peering Spoke B to Hub
#Note this is cross-region
resource "azurerm_virtual_network_peering" "peerSpokeBToHub" {
  name                         = "peering-spokeB-Hub"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.spokeB-vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet-hub.id
  allow_virtual_network_access = true
}
#Peering Hub to Spoke B 
#Note this is cross-region
resource "azurerm_virtual_network_peering" "peerHubToSpokeB" {
  name                         = "peering-hub-SpokeB"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnet-hub.name
  remote_virtual_network_id    = azurerm_virtual_network.spokeB-vnet.id
  allow_virtual_network_access = true
}

