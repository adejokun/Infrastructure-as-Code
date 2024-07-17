
#############################################################################
# RESOURCES
#############################################################################


resource "azurerm_resource_group" "example" {
  name     = var.resource_group
  location = var.location
}

resource "azurerm_virtual_network" "example" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "vm" {  
  name                 = "${var.subnet_name}-vm"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = var.address_prefixes
}

resource "azurerm_network_security_group" "vmss" {
  name                = var.network_security_group
  location            = var.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                        = "allow-internet"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "*"
    source_port_range           = "*"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
}
}

resource "azurerm_orchestrated_virtual_machine_scale_set" "example" {
  name                = var.virtual_machine_scale_set
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = "Standard_F2"
  instances           = 2
  
  platform_fault_domain_count = 1

  zones = ["3"]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_profile {
   linux_configuration {
    admin_username      = "adminuser"
    admin_password      = "P@ssw0rd1234!"
    disable_password_authentication = false
  } 
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nic-vmss"
    primary = true
    network_security_group_id = azurerm_network_security_group.vmss.id
  

    ip_configuration {
      name      = "ipconfig-vmss"
      primary   = true
      application_gateway_backend_address_pool_ids = [tolist(azurerm_application_gateway.network.backend_address_pool).0.id]

    
      public_ip_address {
        name    = "pip-vmss"
        sku_name = "Standard_Regional"
      }

      subnet_id = azurerm_subnet.vm.id
    }
    
  }
  user_data_base64 = base64encode("${file("script.sh")}")

  
}

