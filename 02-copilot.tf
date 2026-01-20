# -------------------------
# Resource Group
# -------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-asiwko"
  location = "eastus"
}

# -------------------------
# Virtual Network (VPC)
# -------------------------
resource "azurerm_virtual_network" "custom_vnet" {
  name                = "custom-vnet"
  address_space       = ["192.168.52.0/23"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# -------------------------
# Subnet (Public Subnet)
# -------------------------
resource "azurerm_subnet" "public_subnet" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.custom_vnet.name
  address_prefixes     = ["192.168.52.0/24"]
}

# -------------------------
# Public IPs (one per VM)
# -------------------------
resource "azurerm_public_ip" "pip_01" {
  name                = "public-ip-01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "pip_04" {
  name                = "public-ip-04"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# -------------------------
# Network Security Group (Security Group)
# -------------------------
resource "azurerm_network_security_group" "public_access" {
  name                = "allow_ssh_http_ping"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ICMP"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "OutboundAll"
    priority                   = 140
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# -------------------------
# Route Table (Public Route)
# -------------------------
resource "azurerm_route_table" "public_rt" {
  name                = "public-route-table"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name           = "default-route"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

# Associate route table with subnet
resource "azurerm_subnet_route_table_association" "public_assoc" {
  subnet_id      = azurerm_subnet.public_subnet.id
  route_table_id = azurerm_route_table.public_rt.id
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.public_subnet.id
  network_security_group_id = azurerm_network_security_group.public_access.id
}

# -------------------------
# Network Interfaces (NICs)
# -------------------------
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

resource "azurerm_network_interface" "nic_04" {
  name                = "nic-04"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_04.id
  }
}

# Attach NSG to NICs (AWS-style behavior)
resource "azurerm_network_interface_security_group_association" "nic_01_assoc" {
  network_interface_id      = azurerm_network_interface.nic_01.id
  network_security_group_id = azurerm_network_security_group.public_access.id
}

resource "azurerm_network_interface_security_group_association" "nic_04_assoc" {
  network_interface_id      = azurerm_network_interface.nic_04.id
  network_security_group_id = azurerm_network_security_group.public_access.id
}

# -------------------------
# Virtual Machines (EC2 Instances)
# -------------------------
resource "azurerm_linux_virtual_machine" "vm_01" {
  name                = "asiwko-vm-01"
  computer_name       = "asiwko-vm-01"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  # size                = "Standard_D2s_v5"
  size                = "Standard_L2aos_v4"

  admin_username = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nic_01.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
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

# resource "azurerm_linux_virtual_machine" "vm_04" {
#   name                = "asiwko-vm-04"
#   computer_name       = "asiwko-vm-04"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   # size                = "Standard_D2s_v5"
#   size                = "Standard_L2aos_v4"

#   admin_username = "azureuser"

#   network_interface_ids = [
#     azurerm_network_interface.nic_04.id,
#   ]

#   admin_ssh_key {
#     username   = "azureuser"
#     public_key = file("/container_shared/ansible/id_rsa.desktop.pub")
#   }

#   os_disk {
#     name                 = "asiwko-vm-04-osdisk"
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }

#   source_image_reference {
#     publisher = "RedHat"
#     offer     = "RHEL"
#     sku       = "97-gen2"
#     version   = "latest"
#   }
# }
