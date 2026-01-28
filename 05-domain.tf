# use this once to get the zone into the state file
# terraform import linode_domain.siwko_org 1228113

# This will update the dns records in my siwko.org domain for the new instances.
resource "linode_domain" "siwko_org" {
    type = "master"
    domain = "siwko.org"
    soa_email = "asiwko@siwko.org"
    refresh_sec = 30
    retry_sec   = 30
    ttl_sec     = 30
}

# Records for the public IP addresses.
resource "linode_domain_record" "az01_siwko_org" {
    domain_id = linode_domain.siwko_org.id
    name = "az01"
    record_type = "A"
    ttl_sec = 5
    target = azurerm_linux_virtual_machine.vm_01.public_ip_address
}


