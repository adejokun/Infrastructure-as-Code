#############################################################################
# TERRAFORM CONFIG
#############################################################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}


#############################################################################
# PROVIDERS
#############################################################################

provider "azurerm" {
  features {}
}

#############################################################################
# RESOURCES
#############################################################################


# Create Azure Virtual Network - Web

resource "azurerm_virtual_network" "web" {
  name                = var.vnet_name_web
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_cidr_range_web

# Create Subnet - Web
  subnet {
    name           = var.subnet_names_web
    address_prefix = var.subnet_prefixes_web
  }

    tags = {
    team = "web team"
  }
}



# Create Azure Virtual Network - Db

resource "azurerm_virtual_network" "db" {
  name                = var.vnet_name_db
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_cidr_range_db

# Create Subnet - Db
  subnet {
    name           = var.subnet_names_db
    address_prefix = var.subnet_prefixes_db
  }

    tags = {
    team = "Database team"
  }
}


#############################################################################
# VNET PEERING
#############################################################################
resource "azurerm_virtual_network_peering" "web-db" {
  name                      = "web-db"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.web.name
  remote_virtual_network_id = azurerm_virtual_network.db.id
}


resource "azurerm_virtual_network_peering" "db-web" {
  name                      = "db-web"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.db.name
  remote_virtual_network_id = azurerm_virtual_network.web.id
}


