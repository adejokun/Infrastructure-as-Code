#############################################################################
# VARIABLES VM1
#############################################################################


variable "location"{
    default = "East US"
}

variable "resource_group"{
    default = "rg-vmss-eus-01"
}

variable "vnet_name"{
    default = "vnet-vmss-01"
}

variable "address_space"{
    default = ["10.0.0.0/16"]
}

variable "subnet_name" {
   default = "subnet-vnet-vmss-01" 
}

variable "address_prefixes"{
    default = ["10.0.2.0/24"]
}

variable "vm_size"{
    default = "Standard_B2s"
}

variable "admin_username"{
    default = "adminuser"
}


variable "public_ip"{
    default = "pip-vmss-01"
}

variable "network_security_group"{
    default = "nsg-vm-vmss-01"
}

variable "load_balancer" {
    default = "lb-vmss-01"
}

variable "virtual_machine_scale_set" {
    default = "vm-vmss-01"
}
