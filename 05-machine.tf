resource "azurerm_network_interface" "nic_01" {
  name                = "nic-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_01.id
  }
}


# Attach NSG to NICs 
resource "azurerm_network_interface_security_group_association" "nic_01_assoc" {
  network_interface_id      = azurerm_network_interface.nic_01.id
  network_security_group_id = azurerm_network_security_group.public_access.id
}


resource "azurerm_linux_virtual_machine" "vm_01" {
  name                = "asiwko-vm-01"
  computer_name       = "asiwko-vm-01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.instance_type

  admin_username = 

  network_interface_ids = [
    azurerm_network_interface.nic_01.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("/container_shared/ansible/ansible_rsa.pub")
  }

  os_disk {
    name                 = "asiwko-vm-01-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "97-gen2"
    version   = "latest"
  }
}

