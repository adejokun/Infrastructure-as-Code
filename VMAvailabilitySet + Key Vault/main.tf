# Creates a virtual machine availability Set and leverages the variable terraform file
# Creates a random password that will be used as the password for the VM
# Creates an Azure Key Vault that will store the password for the VM
# Stores the terraform state file in a 'backend' storage account in the cloud for remote access to all collaborators

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
  backend "azurerm" {
      resource_group_name  = "rg" # Input your resource Group
      storage_account_name = "" # Inpur your storage account
      container_name       = "" # Inpur your container
      key                  = "" # Inpur your container credential
  }
}

#############################################################################
# PROVIDERS
#############################################################################

provider "azurerm" {
  features {}
}


#############################################################################
# Key Vault RESOURCES
#############################################################################

# This Terraform data source provided by the AzureRM (Azure Provider for Terraform) is used to query and
# retrieve the Azure Client Configuration (e.g. Tenant ID, Subscription ID and other authentication-related information)
data "azurerm_client_config" "current" {}

# Keyvault Creation
resource "azurerm_key_vault" "kv1" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "List",
      "Recover"
    ]

    # storage_permissions = [
    #   "get",
    # ]
  }
    
}

#Create KeyVault VM password
resource "random_password" "vmpassword" {
  length = 20
  special = true
}

#Create Key Vault Secret - Password
resource "azurerm_key_vault_secret" "vmpassword" {
  name         = "vmpassword"
  value        = random_password.vmpassword.result
  key_vault_id = azurerm_key_vault.kv1.id
  depends_on = [ azurerm_key_vault.kv1 ]
}

#Create Key Vault Secret - Username
resource "azurerm_key_vault_secret" "username" {
  name         = "UserLogin"
  value        = var.admin_username
  key_vault_id = azurerm_key_vault.kv1.id
  depends_on = [ azurerm_key_vault.kv1 ]
}


#############################################################################
# VM 1
#############################################################################

resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_subnet" "internal" {
  name                 = "snet-${var.vnet_name}"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.address_prefixes
}

resource "azurerm_public_ip" "pip" {
  name                    = var.public_ip
  location                = var.location
  resource_group_name     = var.resource_group
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30

}

resource "azurerm_network_interface" "main" {
  name                = "nic-${var.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_security_group" "inwayz" {
  name                = var.network_security_group
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                        = "allow-rdp"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "3389"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
}
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = var.vm_name
  depends_on = [ azurerm_key_vault.kv1 ]
  resource_group_name = var.resource_group
  location            = var.location
  size                = var.vm_size
  admin_username      = azurerm_key_vault_secret.username.value
  admin_password      = azurerm_key_vault_secret.vmpassword.value
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]
  availability_set_id = azurerm_availability_set.example.id

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}



########################################################################################################################
# VM 2 - No need to create another Vnet/Subnet; both VM's should be in same Vnet if associated with an availability set
########################################################################################################################

resource "azurerm_public_ip" "pip2" {
  name                    = var.public_ip2
  location                = var.location
  resource_group_name     = var.resource_group
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30

}

resource "azurerm_network_interface" "main2" {
  name                = "nic-${var.vm_name2}"
  location            = var.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip2.id
  }
}

resource "azurerm_network_security_group" "inwayz2" {
  name                = var.network_security_group2
  location            = var.location
  resource_group_name = var.resource_group

  security_rule {
    name                        = "allow-rdp"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "3389"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
}
}

resource "azurerm_windows_virtual_machine" "example2" {
  name                = var.vm_name2
  depends_on = [ azurerm_key_vault.kv1 ]
  resource_group_name = var.resource_group
  location            = var.location
  size                = var.vm_size
  admin_username      = azurerm_key_vault_secret.username.value
  admin_password      = azurerm_key_vault_secret.vmpassword.value
  network_interface_ids = [
    azurerm_network_interface.main2.id,
  ]
  availability_set_id = azurerm_availability_set.example.id

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

#############################################################################
# Availabilty Set
#############################################################################

resource "azurerm_availability_set" "example" {
  name                = var.availability_set
  location            = var.location
  resource_group_name = var.resource_group

  tags = {
    environment = "Production"
  }
}