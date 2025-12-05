output "vm_id" {
  description = "The ID of the Linux virtual machine"
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.name
}

output "admin_username" {
  description = "The admin username for the virtual machine"
  value       = azurerm_linux_virtual_machine.main.admin_username
}

output "vm_size" {
  description = "The size/SKU of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.size
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = azurerm_subnet.main.id
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = azurerm_subnet.main.name
}

output "network_interface_id" {
  description = "The ID of the network interface"
  value       = azurerm_network_interface.main.id
}

output "network_interface_name" {
  description = "The name of the network interface"
  value       = azurerm_network_interface.main.name
}

output "network_security_group_id" {
  description = "The ID of the network security group"
  value       = azurerm_network_security_group.main.id
}

output "network_security_group_name" {
  description = "The name of the network security group"
  value       = azurerm_network_security_group.main.name
}

output "primary_public_ip" {
  description = "The primary public IP address of the VM"
  value       = azurerm_public_ip.primary.ip_address
}

output "primary_public_ip_id" {
  description = "The ID of the primary public IP resource"
  value       = azurerm_public_ip.primary.id
}

output "secondary_public_ips" {
  description = "List of secondary public IP addresses"
  value       = azurerm_public_ip.secondary[*].ip_address
}

output "all_public_ips" {
  description = "All public IP addresses (primary + secondary)"
  value = concat(
    [azurerm_public_ip.primary.ip_address],
    azurerm_public_ip.secondary[*].ip_address
  )
}

output "primary_private_ip" {
  description = "The primary private IP address of the VM"
  value       = local.private_ips[0]
}

output "secondary_private_ips" {
  description = "List of secondary private IP addresses"
  value       = slice(local.private_ips, 1, length(local.private_ips))
}

output "all_private_ips" {
  description = "All private IP addresses (primary + secondary)"
  value       = local.private_ips
}

output "ip_mapping" {
  description = "Mapping of private IP addresses to their corresponding public IPs"
  value = {
    for i in range(local.total_ip_count) :
    local.private_ips[i] => i == 0 ? azurerm_public_ip.primary.ip_address : azurerm_public_ip.secondary[i - 1].ip_address
  }
}

output "public_ip_ids" {
  description = "List of all public IP resource IDs"
  value = concat(
    [azurerm_public_ip.primary.id],
    azurerm_public_ip.secondary[*].id
  )
}

output "ssh_connection_string" {
  description = "SSH connection string for the primary IP"
  value       = "ssh ${azurerm_linux_virtual_machine.main.admin_username}@${azurerm_public_ip.primary.ip_address}"
}

output "ssh_connection_strings" {
  description = "SSH connection strings for all public IPs"
  value = [
    for ip in concat([azurerm_public_ip.primary.ip_address], azurerm_public_ip.secondary[*].ip_address) :
    "ssh ${azurerm_linux_virtual_machine.main.admin_username}@${ip}"
  ]
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = var.resource_group_name
}

output "location" {
  description = "The Azure region where resources are deployed"
  value       = var.location
}

output "ip_count" {
  description = "Total number of IP addresses (primary + secondary)"
  value       = local.total_ip_count
}

output "tags" {
  description = "Tags applied to resources"
  value       = var.tags
}
