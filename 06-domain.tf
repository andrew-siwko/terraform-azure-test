# ONLY for the siwko.org domain on Linode
# use this once to get the zone into the state file
# terraform import linode_domain.domain_name 3417841

# This will update the dns records in my siwko.org domain for the new instances.
resource "linode_domain" "dns_zone" {
  type        = "master"
  domain      = var.domain_name
  soa_email   = var.domain_soa_email
  refresh_sec = 30
  retry_sec   = 30
  ttl_sec     = 30
  lifecycle {
    prevent_destroy = true
  }
}

# Records for the public IP addresses.
resource "linode_domain_record" "az01_siwko_org" {
  domain_id   = linode_domain.siwko_org.id
  name        = "az01"
  record_type = "A"
  ttl_sec     = 5
  target      = azurerm_linux_virtual_machine.vm_01.public_ip_address
}


