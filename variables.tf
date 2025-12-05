variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "rg-multi-ip-test"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "name" {
  description = "Base name for resources (will be used as prefix)"
  type        = string
  default     = "multi-ip"
}

variable "secondary_ip_count" {
  description = "Number of secondary public IPs to create (in addition to primary)"
  type        = number
  default     = 5
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "Size of the VM (e.g., Standard_D2s_v5, Standard_B2s)"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_address_prefix" {
  description = "Address prefix for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_ip_start" {
  description = "Starting IP address for private IPs"
  type        = string
  default     = "10.0.1.100"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    environment = "test"
    purpose     = "multi-ip-vm"
  }
}
