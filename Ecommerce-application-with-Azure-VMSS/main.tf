
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

locals {
  instance_count = 2
}

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

resource "azurerm_subnet" "example" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = var.address_prefixes
}

resource "azurerm_public_ip" "example" {
  name                = var.public_ip
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
  domain_name_label   = azurerm_resource_group.example.name
}

resource "azurerm_lb" "example" {
  name                = var.load_balancer
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_lb_backend_address_pool" "example" {
  loadbalancer_id     = azurerm_lb.example.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "example" {
  loadbalancer_id     = azurerm_lb.example.id
  name                = "ssh-probe"
  protocol            = "Tcp"
  port                = 22
}

resource "azurerm_lb_nat_pool" "example" {
  resource_group_name            = azurerm_resource_group.example.name
  name                           = "ssh"
  loadbalancer_id                = azurerm_lb.example.id
  protocol                       = "Tcp"
  frontend_port_start            = 220
  frontend_port_end              = 229
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}


resource "azurerm_linux_virtual_machine_scale_set" "example" {
  name                            = var.virtual_machine_scale_set
  resource_group_name             = azurerm_resource_group.example.name
  location                        = azurerm_resource_group.example.location
  sku                             = "Standard_F2"
  instances                       = 2
  admin_username                  = "adminuser"
  admin_password                  = "P@ssw0rd1234!"
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  network_interface {
    name    = "nic-vmss"
    primary = true

    ip_configuration {
      name      = "pip-m=vmss"
      primary   = true
      subnet_id = azurerm_subnet.example.id
    }
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}

resource "azurerm_monitor_autoscale_setting" "example" {
  name                = "autoscale-cpu"
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.example.id
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  profile {
    name = "autoscale-cpu"

    capacity {
      default = local.instance_count
      minimum = 1
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.example.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.example.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 15
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "example" {
  name                         = "example"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.example.id
  publisher                    = "Microsoft.Azure.Extensions"
  type                         = "CustomScript"
  type_handler_version         = "2.0"
  settings = jsonencode({
    "fileUris" = ""
    "commandToExecute" = "echo $HOSTNAME"
  })
}