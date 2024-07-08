#############################################################################
# VARIABLES VM1
#############################################################################

variable "vm_name" {
  default = "vm-web-inwayz01"
}

variable "location"{
    default = "East US"
}

# Input your resource Group
variable "resource_group"{
    default = "rg"
}

variable "vnet_name"{
    default = "vnet-dev-web-001"
}

variable "address_space"{
    default = ["10.0.0.0/16"]
}

variable "address_prefixes"{
    default = ["10.0.0.0/24"]
}

variable "vm_size"{
    default = "Standard_B2s"
}

variable "admin_username"{
    default = "adminuser"
}

variable "key_vault_name"{
    default = "kv-vm-web-inwayz03"
}

variable "public_ip"{
    default = "pip-web-inwayz01"
}

variable "network_security_group"{
    default = "nsg-vm-web-inwayz01"
}


#############################################################################
# VARIABLES VM2
#############################################################################
variable "vm_name2" {
  default = "vm-web-inwayz02"
}

variable "vnet_name2"{
    default = "vnet-dev-web-002"
}

variable "public_ip2"{
    default = "pip-web-inwayz02"
}

variable "network_security_group2"{
    default = "nsg-vm-web-inwayz02"
}

#############################################################################
# Availability set
#############################################################################

variable "availability_set"{
    default = "my_set"
}
