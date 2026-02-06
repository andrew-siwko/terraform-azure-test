variable "LINODE_API_KEY" {
  description = "The key to the Linode API"
  type        = string
  sensitive   = true
}

variable "instance_region" {
  description = "The region to create the Linode instance"
  type        = string
  default     = "us-southeast"
}

variable "instance_type" {
  description = "Which instance type to create"
  type    = string
  default = "g6-nanode-1"
}

variable "domain_name" {
  description = "The domain to create instance records in."
  type    = string
  default = "siwko.org"
}

variable "admin_username" {
  description = "The root user."
  type    = string
  default = "root"
}

variable "domain_soa_email" {
  description = "The domain manager e-mail address."
  type    = string
  default = "asiwko@siwko.org"
}