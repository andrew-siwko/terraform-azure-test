terraform {
  required_providers {
    # We will be working with Azure and so will need the Azure provider
    azurerm = {
      source  = "hashicorp/azurerm"
    }
    # in order to update DNS on linode, we'll need the linode provider.
    linode = {
      source  = "linode/linode"
    }
  }
   backend "local" {
    path = "/container_shared/tfstate/azure.tfstate"
  }

  # This project started with the state stored in the provider's oject storage.  
  # I moved it to local storage as providers charge for object storage and there was no benefit once the exercise was complete.
  # backend "azurerm" {
  #     resource_group_name  = "tfstate"
  #     storage_account_name = "tfstateasiwko01"
  #     container_name       = "tfstate"
  #     key                  = "terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

provider "linode" {
  token = var.LINODE_API_KEY
}

