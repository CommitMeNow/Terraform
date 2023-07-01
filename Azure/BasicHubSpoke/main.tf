#******EXAMPLE NOTES**************************************************
#This creates a very basic hub and spoke architecture with cross-region peering. 
#The spokes are not currently configured to speak to each other. To make the spokes able to communicate
#peer them directly together or implement vNET gateway with S2S peering between spokes and leveage BGB with UDR
#
#This example only allows private network communication and VMs are not setup to be access via public. 
#Enhance with NSGs and PIPs for more in-depth scenarios. 
#
#Tagging Polciies are not in use for this example
#*********************************************************************
#Resource Group for Entire Deployment
resource "azurerm_resource_group" "rg" {
    name = var.resourceGroupName
    location = var.deploymentLocation
}

#------------------------------------------------------------------------------------
#Create VM01 which will reside in the same region as the default deployment
resource "azurerm_network_interface" "nic-vm01" {
  name                = "nic-vm01"
  location            = var.deploymentLocation
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipConfig-dynamic"
    subnet_id                     = azurerm_subnet.spokeA-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#Create VM01
resource "azurerm_windows_virtual_machine" "vm-01" {
  name                = "vm-01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.deploymentLocation
  size                = "Standard_B2ms"
  admin_username      = var.windowsUsername
  admin_password      = var.userPWD
  network_interface_ids = [
    azurerm_network_interface.nic-vm01.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

#------------------------------------------------------------------------------------
#Create VM02 which will reside in a separate region from the main deployment but the same resource group

#Create VM02 NIC
resource "azurerm_network_interface" "nic-vm02" {
  name                = "nic-vm02"
  location            = "westus"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipConfig-dynamic"
    subnet_id                     = azurerm_subnet.spokeB-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#Create VM01
resource "azurerm_windows_virtual_machine" "vm-02" {
  name                = "vm-02"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "westus"
  size                = "Standard_B2ms"
  admin_username      = var.windowsUsername
  admin_password      = var.userPWD
  network_interface_ids = [
    azurerm_network_interface.nic-vm02.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
#------------------------------------------------------------------------------------

#------------------------------------------------------------------------------------
#Create VM03 which will reside in the HUB and default deployment location
resource "azurerm_network_interface" "nic-vm03" {
  name                = "nic-vm03"
  location            = var.deploymentLocation
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipConfig-dynamic"
    subnet_id                     = azurerm_subnet.hub-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

#Create VM01
resource "azurerm_windows_virtual_machine" "vm-03" {
  name                = "vm-03"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.deploymentLocation
  size                = "Standard_B2ms"
  admin_username      = var.windowsUsername
  admin_password      = var.userPWD
  network_interface_ids = [
    azurerm_network_interface.nic-vm03.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

#------------------------------------------------------------------------------------




