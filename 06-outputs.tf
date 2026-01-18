# output "ARM_SUBSCRIPTION_ID" {
#   value = var.ARM_SUBSCRIPTION_ID
# }
# output "ARM_TENANT_ID" {
#   value = var.ARM_TENANT_ID
# }

# output "ARM_CLIENT_ID" {
#   value = var.ARM_CLIENT_ID
# }
output "asiwko-vm-public-ip_03" {
  value = azurerm_linux_virtual_machine.vm_03.public_ip_address
}
# output "asiwko-vm-public-ip_04" {
#   value = azurerm_linux_virtual_machine.vm_04.public_ip_address
# }
