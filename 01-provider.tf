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
  # We want to store the Terraform state file in azure using an storage account.
  backend "azurerm" {
      resource_group_name  = "tfstate"
      storage_account_name = "tfstateasiwko01"
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


# resource "azurerm_resource_group" "state-demo-secure" {
#   name     = "state-demo"
#   location = "eastus"
# }

provider "azurerm" {
  features {}
}