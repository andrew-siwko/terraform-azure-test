resource "azurerm_resource_group" "rg" {
  name     = "rg-asiwko"
  location = "eastus"
}

resource "azurerm_virtual_network" "custom_vnet" {
  name                = "custom-vnet"
  address_space       = ["192.168.52.0/23"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "public_subnet" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.custom_vnet.name
  address_prefixes     = ["192.168.52.0/24"]
}

resource "azurerm_public_ip" "pip_01" {
  name                = "public-ip-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

