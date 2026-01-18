# This will update the dns records in my siwko.org domain for the new instances.
resource "linode_domain" "siwko_org" {
    type = "master"
    domain = "siwko.org"
    soa_email = "asiwko@siwko.org"
    refresh_sec = 300
    retry_sec   = 300
    ttl_sec     = 300
}

# Records for the public IP addresses.
resource "linode_domain_record" "az03_siwko_org" {
    domain_id = linode_domain.siwko_org.id
    name = "az03"
    record_type = "A"
    ttl_sec = 5
    target = azurerm_linux_virtual_machine.vm_03.public_ip_address
}


