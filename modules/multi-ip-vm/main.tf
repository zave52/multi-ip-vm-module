locals {
  ip_parts      = split(".", var.private_ip_start)
  ip_base       = "${local.ip_parts[0]}.${local.ip_parts[1]}.${local.ip_parts[2]}"
  ip_start_host = tonumber(local.ip_parts[3])

  total_ip_count = var.secondary_ip_count + 1

  private_ips = [
    for i in range(local.total_ip_count) :
    "${local.ip_base}.${local.ip_start_host + i}"
  ]
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.name}-vnet"
  address_space       = [var.vnet_address_space]
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_subnet" "main" {
  name                 = "${var.name}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_address_prefix]
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  tags = var.tags
}

resource "azurerm_public_ip" "primary" {
  name                = "${var.name}-pip-primary"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku

  tags = merge(var.tags, {
    ip_type = "primary"
  })
}

resource "azurerm_public_ip" "secondary" {
  count               = var.secondary_ip_count
  name                = "${var.name}-pip-secondary-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku

  tags = merge(var.tags, {
    ip_type = "secondary"
    index   = count.index + 1
  })
}

resource "azurerm_network_interface" "main" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig-primary"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.private_ips[0]
    public_ip_address_id          = azurerm_public_ip.primary.id
    primary                       = true
  }

  dynamic "ip_configuration" {
    for_each = range(var.secondary_ip_count)
    content {
      name                          = "ipconfig-secondary-${ip_configuration.value + 1}"
      subnet_id                     = azurerm_subnet.main.id
      private_ip_address_allocation = "Static"
      private_ip_address            = local.private_ips[ip_configuration.value + 1]
      public_ip_address_id          = azurerm_public_ip.secondary[ip_configuration.value].id
      primary                       = false
    }
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "${var.name}-vm"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    name                 = "${var.name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_type
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  disable_password_authentication = true

  tags = var.tags
}
