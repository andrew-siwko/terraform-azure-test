output "azure_instance_public_ip" {
  value = azurerm_linux_virtual_machine.vm_01.public_ip_address
}
