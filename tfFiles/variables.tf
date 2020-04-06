##################################################################################
# VARIABLES
##################################################################################

variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

variable "resource_group" {
  default     = "Technology-RG"
  description = "The resource group used in Azure"
}

variable "virtual_network" {
  default     = "Technology-Vnet"
  description = "The virtual network of Technology-RG used in Azure"
}

variable "subnet" {
  default     = "Application"
  description = "The subnet of Technology-RG used in Azure"
}

variable "prefix" {
  default     = "Technology-"
  description = "The prefix which should be used for all resources"
}

variable "location" {
  default     = "West Europe"
  description = "The Azure Region in which all resources in this example should be created"
}

variable "disk_type" {
  default     = "standard_lrs"
  description = "The type of the disk of the created virtual machine"
}

variable "vm_name" {
  default     = "Technology-Automated"
  description = "The name of the created virtual machine"
}

variable "vm_size" {
  default     = "Standard_D2_v2"
  description = "The size of the created virtual machine"
}