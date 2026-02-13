variable "LINODE_API_KEY" {
  description = "The key to the Linode API"
  type        = string
  sensitive   = true
}

variable "instance_region" {
  description = "The region to create the instance"
  type        = string
  default     = "us-southeast"
}

variable "instance_type" {
  description = "Which instance type to create"
  type    = string
  default = "Standard_L2aos_v4"
}

variable "domain_name" {
  description = "The domain to create instance records in."
  type    = string
  default = "siwko.org"
}

variable "admin_username" {
  description = "The root user."
  type    = string
  default = "azureuser"
}

variable "domain_soa_email" {
  description = "The domain manager e-mail address."
  type    = string
  default = "asiwko@siwko.org"
}
variable "rg_location" {
  description = "The location of the resource group."
  type    = string
  default = "eastus"
}
