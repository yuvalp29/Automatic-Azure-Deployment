variable "subscription_id" {
  default     = "35a022b0-938c-4075-bee9-58add25f07a3"
}

variable "client_id" {
  default     = "e135aa97-15a7-46da-9d2a-6c18e47bf7eb"
}

variable "client_secret" {
  default     = "3cb64ca4-82f8-495e-bf35-c121e8b316e1"
}

variable "tenant_id" {
  default     = "093e934e-7489-456c-bb5f-8bb6ea5d829c"
}

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

variable "vm_type" {
  default     = "Linux Ubuntu 16.04"
  description = "The image type of the created virtual machine"
}

variable "vm_name" {
  default     = "Technology-Automated"
  description = "The name of the created virtual machine"
}

variable "vm_size" {
  default     = "Standard_D2_v2"
  description = "The size of the created virtual machine"
}