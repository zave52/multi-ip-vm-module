output "primary_public_ip" {
  description = "Primary public IP address of the VM (required by task)"
  value       = module.multi_ip_vm.primary_public_ip
}

output "admin_username" {
  description = "Admin username for SSH access to the VM (required by task)"
  value       = module.multi_ip_vm.admin_username
}

output "all_public_ips" {
  description = "List of all public IP addresses for verification (required by task)"
  value       = module.multi_ip_vm.all_public_ips
}

output "ssh_connection_string" {
  description = "SSH connection string to connect to the VM using the primary IP"
  value       = module.multi_ip_vm.ssh_connection_string
}

output "ssh_connection_strings" {
  description = "SSH connection strings for all public IPs"
  value       = module.multi_ip_vm.ssh_connection_strings
}

output "secondary_public_ips" {
  description = "List of secondary public IP addresses only"
  value       = module.multi_ip_vm.secondary_public_ips
}

output "all_private_ips" {
  description = "List of all private IP addresses (primary + secondary)"
  value       = module.multi_ip_vm.all_private_ips
}

output "secondary_private_ips" {
  description = "List of secondary private IP addresses only"
  value       = module.multi_ip_vm.secondary_private_ips
}

output "ip_mapping" {
  description = "Mapping of private IP addresses to their corresponding public IPs"
  value       = module.multi_ip_vm.ip_mapping
}

output "ip_count" {
  description = "Total number of IP addresses configured (primary + secondary)"
  value       = module.multi_ip_vm.ip_count
}

output "resource_group_name" {
  description = "Name of the resource group where all resources are deployed"
  value       = azurerm_resource_group.main.name
}

output "location" {
  description = "Azure region where resources are deployed"
  value       = azurerm_resource_group.main.location
}

output "vm_id" {
  description = "The ID of the Linux virtual machine"
  value       = module.multi_ip_vm.vm_id
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = module.multi_ip_vm.vm_name
}

output "vm_size" {
  description = "The size of the virtual machine"
  value       = module.multi_ip_vm.vm_size
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = module.multi_ip_vm.vnet_id
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = module.multi_ip_vm.vnet_name
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = module.multi_ip_vm.subnet_id
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = module.multi_ip_vm.subnet_name
}

output "network_interface_id" {
  description = "The ID of the network interface"
  value       = module.multi_ip_vm.network_interface_id
}

output "network_interface_name" {
  description = "The name of the network interface"
  value       = module.multi_ip_vm.network_interface_name
}

output "network_security_group_id" {
  description = "The ID of the network security group"
  value       = module.multi_ip_vm.network_security_group_id
}

output "network_security_group_name" {
  description = "The name of the network security group"
  value       = module.multi_ip_vm.network_security_group_name
}

output "public_ip_ids" {
  description = "List of all public IP resource IDs"
  value       = module.multi_ip_vm.public_ip_ids
}

output "deployment_summary" {
  description = "Summary of the deployment with key information"
  value = {
    resource_group = azurerm_resource_group.main.name
    location       = azurerm_resource_group.main.location
    vm_name        = module.multi_ip_vm.vm_name
    vm_size        = module.multi_ip_vm.vm_size
    admin_user     = module.multi_ip_vm.admin_username
    ip_count       = module.multi_ip_vm.ip_count
    primary_ip     = module.multi_ip_vm.primary_public_ip
    ssh_command    = module.multi_ip_vm.ssh_connection_string
    all_public_ips = module.multi_ip_vm.all_public_ips
  }
}
