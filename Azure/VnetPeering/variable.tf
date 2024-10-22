#############################################################################
# VARIABLES
#############################################################################

variable "resource_group_name" {
  type = string
  default = "rg-vnetpeering-eus-01" 
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "vnet_name_web" {
  type    = string
  default = "vnet-web-cc-001"
}

variable "vnet_name_db" {
  type    = string
  default = "vnet-db-cc-001"
}

variable "vnet_cidr_range_web" {
  type    = list(string)
  default = ["10.100.0.0/16"]
}

variable "vnet_cidr_range_db" {
  type    = list(string)
  default = ["10.120.0.0/16"]
}

variable "subnet_prefixes_web" {
  type    = string
  default = "10.100.0.0/24"
}

variable "subnet_prefixes_db" {
  type    = string
  default = "10.120.0.0/24"
}

variable "subnet_names_web" {
  type    = string
  default = "snet-vnet-web-cc-001"
}

variable "subnet_names_db" {
  type    = string
  default = "snet-vnet-db-cc-001"
}