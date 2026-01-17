terraform {
  required_providers {
    # We will be working with AWS and so will need the AWS provider
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    # in order to update DNS on linode, we'll need the linode provider.
    linode = {
      source  = "linode/linode"
    }
  }
  # We want to store the Terraform state file in aws using an S3 bucket.
  backend "azurerm" {
      resource_group_name  = "tfstate"
      storage_account_name = "tfstate-asiwko-01"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }
}


variable "LINODE_API_KEY" {
  description = "The key to the Linode API"
  type        = string
}

provider "linode" {
  token = var.LINODE_API_KEY
}

variable "ARM_SUBSCRIPTION_ID" {
  type    = string
}

variable "ARM_TENANT_ID" {
  type    = string
}

variable "ARM_CLIENT_ID" {
  type    = string
}

variable "ARM_CLIENT_SECRET" {
  type    = string
}

output "ARM_SUBSCRIPTION_ID01" {
  value = var.ARM_SUBSCRIPTION_ID
}
output "ARM_TENANT_ID02" {
  value = var.ARM_TENANT_ID
}

output "ARM_CLIENT_ID03" {
  value = var.ARM_CLIENT_ID
}

# resource "azurerm_resource_group" "state-demo-secure" {
#   name     = "state-demo"
#   location = "eastus"
# }

provider "azurerm" {
  features {}
  # subscription_id   = var.ARM_SUBSCRIPTION_ID
  # tenant_id         = var.ARM_TENANT_ID
  # client_id         = var.ARM_CLIENT_ID
  # client_secret     = var.ARM_CLIENT_SECRET
}