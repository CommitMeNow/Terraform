#******EXAMPLE NOTES**************************************************
#This creates a basic example of private DNS in Azure. 
#The private dns is setup for an example domain  Adventureworks.org
#
#Tagging Polciies are not in use for this example
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
#Create the second subnet
resource "azurerm_subnet" "snet-1"{
    name = "snet-1"
    resource_group_name = azurerm_resource_group.rg-deployment.name
    virtual_network_name = azurerm_virtual_network.vnet-01.name
    address_prefixes = ["10.40.1.0/24"]
    

}
#Create the first public IP
resource "azurerm_public_ip" "pip-00"{
  location            = azurerm_resource_group.rg-deployment.location
  resource_group_name = azurerm_resource_group.rg-deployment.name
  name = "pip-00"
  allocation_method = "Static"  
  sku = "Standard"
}
#Create the second public IP
resource "azurerm_public_ip" "pip-01"{
  location            = azurerm_resource_group.rg-deployment.location
  resource_group_name = azurerm_resource_group.rg-deployment.name
  name = "pip-01"
  allocation_method = "Static"  
  sku = "Standard"
}
#Establish an NSG
resource "azurerm_network_security_group" "nsg01" {
  location            = azurerm_resource_group.rg-deployment.location
  resource_group_name = azurerm_resource_group.rg-deployment.name
  name = "nsg01"
}
#Create NSG rules
resource "azurerm_network_security_rule" "allowRDP" {
  name                        = "AllowRDPInbound"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name = azurerm_resource_group.rg-deployment.name
  network_security_group_name = azurerm_network_security_group.nsg01.name
}
#Create network interfaces
resource "azurerm_network_interface" "nic0" {
  location            = azurerm_resource_group.rg-deployment.location
  resource_group_name = azurerm_resource_group.rg-deployment.name
  name                = "nic0"
  
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-00.id
    subnet_id                     = azurerm_subnet.snet-0.id 
  }

}
resource "azurerm_network_interface" "nic1" {
  location            = azurerm_resource_group.rg-deployment.location
  resource_group_name = azurerm_resource_group.rg-deployment.name
  name                = "nic1"
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip-01.id
    subnet_id                     = azurerm_subnet.snet-1.id 
  }

}
#Assocaites NGSs to Nics
resource "azurerm_network_interface_security_group_association" "nsg01toNic0" {
  network_interface_id      = azurerm_network_interface.nic0.id
  network_security_group_id = azurerm_network_security_group.nsg01.id
}
resource "azurerm_network_interface_security_group_association" "nsg01toNic1" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.nsg01.id
}

#Create primary V<
resource "azurerm_windows_virtual_machine" "vm0" {
  location            = azurerm_resource_group.rg-deployment.location
  resource_group_name = azurerm_resource_group.rg-deployment.name

  admin_username        = var.windowsUserName
  admin_password        = var.windowsPwd

 
  name                  = "vm0"
  network_interface_ids = [
    azurerm_network_interface.nic0.id,
  ]

  size                  = "Standard_B2ms"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2019-Datacenter-smalldisk"
    version   = "latest"
  }
}

#Create secondary VM
resource "azurerm_windows_virtual_machine" "vm1" {
  location            = azurerm_resource_group.rg-deployment.location
  resource_group_name = azurerm_resource_group.rg-deployment.name

  admin_username        = var.windowsUserName
  admin_password        = var.windowsPwd

   name                  = "vm1"
  network_interface_ids = [
    azurerm_network_interface.nic1.id,
  ]

  size                  = "Standard_B2ms" 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2019-Datacenter-smalldisk"
    version   = "latest"
  }
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



