variable "name" {
  description = "Base name for resources (will be used as prefix)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "secondary_ip_count" {
  description = "Number of secondary public IPs"
  type        = number
}

variable "private_ip_start" {
  description = "Starting IP address for private IPs"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for VNet"
  type        = string
}

variable "subnet_address_prefix" {
  description = "Address prefix for subnet"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "security_rules" {
  description = "List of security rules for NSG"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = [
    {
      name                       = "SSH"
      priority                   = 1001
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowOutbound"
      priority                   = 1002
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}

variable "public_ip_allocation_method" {
  description = "Public IP allocation method (Static or Dynamic)"
  type        = string
  default     = "Static"

  validation {
    condition     = contains(["Static", "Dynamic"], var.public_ip_allocation_method)
    error_message = "Public IP allocation method must be either 'Static' or 'Dynamic'."
  }
}

variable "public_ip_sku" {
  description = "Public IP SKU (Basic or Standard)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.public_ip_sku)
    error_message = "Public IP SKU must be either 'Basic' or 'Standard'."
  }
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "Size of the VM"
  type        = string
}

variable "vm_image_publisher" {
  description = "Publisher of the VM image"
  type        = string
  default     = "Canonical"
}

variable "vm_image_offer" {
  description = "Offer of the VM image"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "vm_image_sku" {
  description = "SKU of the VM image"
  type        = string
  default     = "22_04-lts-gen2"
}

variable "vm_image_version" {
  description = "Version of the VM image"
  type        = string
  default     = "latest"
}

variable "os_disk_storage_type" {
  description = "Storage account type for OS disk"
  type        = string
  default     = "Premium_LRS"
}
