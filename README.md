# Azure Multi-IP VM Deployment

This project automates the deployment of an Azure Virtual Machine with one primary and multiple secondary public IP
addresses. It uses Terraform for infrastructure provisioning and Ansible for VM configuration.

## Requirements

* [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
* [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

    * Ansible Collections:
      ```bash
      ansible-galaxy collection install -r ansible/requirements.yml
      ```

    * Python libraries for Ansible (before create venv and activate it):
      ```bash
      pip install -r ansible/requirements.txt
      ```

## Usage

1. **Authenticate to Azure:**
   ```bash
   az login
   ```


2. **Configure Terraform:**

    * Copy `terraform.tfvars.example` to `terraform.tfvars`
    * Edit `terraform.tfvars` to add your SSH public key. You can also change other variables like `secondary_ip_count`.

3. **Deploy Infrastructure:**

   Initialize and apply the Terraform configuration.
   ```bash
   terraform init
   terraform apply
   ```


4. **Configure VM with Ansible:**

   Run the Ansible playbook to configure networking inside the VM.

    * To configure the VM **without** running the final verification script (task 2):
      ```bash
      ansible-playbook ansible/playbook.yml
      ```
    * To configure the VM **and** run the final verification script (task 2 + task 3):
      ```bash
      ansible-playbook ansible/playbook.yml --extra-vars "verification_script_path=verification.sh"
      ```

5. **Clean Up:**

   To destroy all resources created by this project, run the cleanup script.
   ```bash
   ./cleanup.sh
   ```

---

## Project Components

### Terraform

The Terraform configuration (`main.tf`, `modules/multi-ip-vm`) provisions all the necessary Azure resources, including:

* A Resource Group in the `eastus` region.
* A Virtual Network and Subnet.
* A Network Security Group with rules to allow SSH.
* A Linux VM with a primary public IP and a variable number of secondary public IPs.

The number of secondary IPs can be controlled with the `secondary_ip_count` variable in `terraform.tfvars`.

### Ansible

The Ansible configuration (`ansible/playbook.yml`, `ansible/roles/multi_ip_networking`) performs the following actions
on the VM:

* Dynamically discovers the target VM using Azure tags.
* Installs `iproute2`.
* Configures Policy-Based Routing (PBR) by creating new routing tables and rules.
* Sets up a `systemd` service to ensure the networking configuration persists after reboots.
* Runs the `verification.sh` script to test the final setup.

### Scripts

* `verification.sh`: A bash script that runs inside the VM to test the multi-IP setup. For each configured private IP,
  it makes an outbound request and verifies that the traffic correctly uses the corresponding public IP.
* `cleanup.sh`: A simple script that runs `terraform destroy` to remove all deployed Azure resources.

---

## Logs & Verification

### Terraform Apply Log

```terminaloutput
zakhar@archlinux ~/D/T/azure_devops
> terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.main will be created
  + resource "azurerm_resource_group" "main" {
      + id       = (known after apply)
      + location = "eastus"
      + name     = "rg-multi-ip-test"
      + tags     = {
          + "environment" = "test"
          + "purpose"     = "multi-ip-vm"
        }
    }

  # module.multi_ip_vm.azurerm_linux_virtual_machine.main will be created
  + resource "azurerm_linux_virtual_machine" "main" {
      + admin_username                                         = "azureuser"
      + allow_extension_operations                             = true
      + bypass_platform_safety_checks_on_user_schedule_enabled = false
      + computer_name                                          = (known after apply)
      + disable_password_authentication                        = true
      + disk_controller_type                                   = (known after apply)
      + extensions_time_budget                                 = "PT1H30M"
      + id                                                     = (known after apply)
      + location                                               = "eastus"
      + max_bid_price                                          = -1
      + name                                                   = "multi-ip-vm"
      + network_interface_ids                                  = (known after apply)
      + patch_assessment_mode                                  = "ImageDefault"
      + patch_mode                                             = "ImageDefault"
      + platform_fault_domain                                  = -1
      + priority                                               = "Regular"
      + private_ip_address                                     = (known after apply)
      + private_ip_addresses                                   = (known after apply)
      + provision_vm_agent                                     = true
      + public_ip_address                                      = (known after apply)
      + public_ip_addresses                                    = (known after apply)
      + resource_group_name                                    = "rg-multi-ip-test"
      + size                                                   = "Standard_L2aos_v4"
      + tags                                                   = {
          + "environment" = "test"
          + "purpose"     = "multi-ip-vm"
        }
      + virtual_machine_id                                     = (known after apply)
      + vm_agent_platform_updates_enabled                      = false

      + admin_ssh_key {
          # At least one attribute in this block is (or was) sensitive,
          # so its contents will not be displayed.
        }

      + os_disk {
          + caching                   = "ReadWrite"
          + disk_size_gb              = (known after apply)
          + name                      = "multi-ip-osdisk"
          + storage_account_type      = "Premium_LRS"
          + write_accelerator_enabled = false
        }

      + source_image_reference {
          + offer     = "0001-com-ubuntu-server-jammy"
          + publisher = "Canonical"
          + sku       = "22_04-lts-gen2"
          + version   = "latest"
        }

      + termination_notification (known after apply)
    }

  # module.multi_ip_vm.azurerm_network_interface.main will be created
  + resource "azurerm_network_interface" "main" {
      + accelerated_networking_enabled = (known after apply)
      + applied_dns_servers            = (known after apply)
      + dns_servers                    = (known after apply)
      + enable_accelerated_networking  = (known after apply)
      + enable_ip_forwarding           = (known after apply)
      + id                             = (known after apply)
      + internal_domain_name_suffix    = (known after apply)
      + ip_forwarding_enabled          = (known after apply)
      + location                       = "eastus"
      + mac_address                    = (known after apply)
      + name                           = "multi-ip-nic"
      + private_ip_address             = (known after apply)
      + private_ip_addresses           = (known after apply)
      + resource_group_name            = "rg-multi-ip-test"
      + tags                           = {
          + "environment" = "test"
          + "purpose"     = "multi-ip-vm"
        }
      + virtual_machine_id             = (known after apply)

      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "ipconfig-primary"
          + primary                                            = true
          + private_ip_address                                 = "10.0.1.100"
          + private_ip_address_allocation                      = "Static"
          + private_ip_address_version                         = "IPv4"
          + public_ip_address_id                               = (known after apply)
          + subnet_id                                          = (known after apply)
        }
      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "ipconfig-secondary-1"
          + primary                                            = false
          + private_ip_address                                 = "10.0.1.101"
          + private_ip_address_allocation                      = "Static"
          + private_ip_address_version                         = "IPv4"
          + public_ip_address_id                               = (known after apply)
          + subnet_id                                          = (known after apply)
        }
      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "ipconfig-secondary-2"
          + primary                                            = false
          + private_ip_address                                 = "10.0.1.102"
          + private_ip_address_allocation                      = "Static"
          + private_ip_address_version                         = "IPv4"
          + public_ip_address_id                               = (known after apply)
          + subnet_id                                          = (known after apply)
        }
      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "ipconfig-secondary-3"
          + primary                                            = false
          + private_ip_address                                 = "10.0.1.103"
          + private_ip_address_allocation                      = "Static"
          + private_ip_address_version                         = "IPv4"
          + public_ip_address_id                               = (known after apply)
          + subnet_id                                          = (known after apply)
        }
      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "ipconfig-secondary-4"
          + primary                                            = false
          + private_ip_address                                 = "10.0.1.104"
          + private_ip_address_allocation                      = "Static"
          + private_ip_address_version                         = "IPv4"
          + public_ip_address_id                               = (known after apply)
          + subnet_id                                          = (known after apply)
        }
      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "ipconfig-secondary-5"
          + primary                                            = false
          + private_ip_address                                 = "10.0.1.105"
          + private_ip_address_allocation                      = "Static"
          + private_ip_address_version                         = "IPv4"
          + public_ip_address_id                               = (known after apply)
          + subnet_id                                          = (known after apply)
        }
    }

  # module.multi_ip_vm.azurerm_network_interface_security_group_association.main will be created
  + resource "azurerm_network_interface_security_group_association" "main" {
      + id                        = (known after apply)
      + network_interface_id      = (known after apply)
      + network_security_group_id = (known after apply)
    }

  # module.multi_ip_vm.azurerm_network_security_group.main will be created
  + resource "azurerm_network_security_group" "main" {
      + id                  = (known after apply)
      + location            = "eastus"
      + name                = "multi-ip-nsg"
      + resource_group_name = "rg-multi-ip-test"
      + security_rule       = [
          + {
              + access                                     = "Allow"
              + destination_address_prefix                 = "*"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "*"
              + destination_port_ranges                    = []
              + direction                                  = "Outbound"
              + name                                       = "AllowOutbound"
              + priority                                   = 1002
              + protocol                                   = "*"
              + source_address_prefix                      = "*"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
                # (1 unchanged attribute hidden)
            },
          + {
              + access                                     = "Allow"
              + destination_address_prefix                 = "*"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "22"
              + destination_port_ranges                    = []
              + direction                                  = "Inbound"
              + name                                       = "SSH"
              + priority                                   = 1001
              + protocol                                   = "Tcp"
              + source_address_prefix                      = "*"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
                # (1 unchanged attribute hidden)
            },
        ]
      + tags                = {
          + "environment" = "test"
          + "purpose"     = "multi-ip-vm"
        }
    }

  # module.multi_ip_vm.azurerm_public_ip.primary will be created
  + resource "azurerm_public_ip" "primary" {
      + allocation_method       = "Static"
      + ddos_protection_mode    = "VirtualNetworkInherited"
      + fqdn                    = (known after apply)
      + id                      = (known after apply)
      + idle_timeout_in_minutes = 4
      + ip_address              = (known after apply)
      + ip_version              = "IPv4"
      + location                = "eastus"
      + name                    = "multi-ip-pip-primary"
      + resource_group_name     = "rg-multi-ip-test"
      + sku                     = "Standard"
      + sku_tier                = "Regional"
      + tags                    = {
          + "environment" = "test"
          + "ip_type"     = "primary"
          + "purpose"     = "multi-ip-vm"
        }
    }

  # module.multi_ip_vm.azurerm_public_ip.secondary[0] will be created
  + resource "azurerm_public_ip" "secondary" {
      + allocation_method       = "Static"
      + ddos_protection_mode    = "VirtualNetworkInherited"
      + fqdn                    = (known after apply)
      + id                      = (known after apply)
      + idle_timeout_in_minutes = 4
      + ip_address              = (known after apply)
      + ip_version              = "IPv4"
      + location                = "eastus"
      + name                    = "multi-ip-pip-secondary-1"
      + resource_group_name     = "rg-multi-ip-test"
      + sku                     = "Standard"
      + sku_tier                = "Regional"
      + tags                    = {
          + "environment" = "test"
          + "index"       = "1"
          + "ip_type"     = "secondary"
          + "purpose"     = "multi-ip-vm"
        }
    }

  # module.multi_ip_vm.azurerm_public_ip.secondary[1] will be created
  + resource "azurerm_public_ip" "secondary" {
      + allocation_method       = "Static"
      + ddos_protection_mode    = "VirtualNetworkInherited"
      + fqdn                    = (known after apply)
      + id                      = (known after apply)
      + idle_timeout_in_minutes = 4
      + ip_address              = (known after apply)
      + ip_version              = "IPv4"
      + location                = "eastus"
      + name                    = "multi-ip-pip-secondary-2"
      + resource_group_name     = "rg-multi-ip-test"
      + sku                     = "Standard"
      + sku_tier                = "Regional"
      + tags                    = {
          + "environment" = "test"
          + "index"       = "2"
          + "ip_type"     = "secondary"
          + "purpose"     = "multi-ip-vm"
        }
    }

  # module.multi_ip_vm.azurerm_public_ip.secondary[2] will be created
  + resource "azurerm_public_ip" "secondary" {
      + allocation_method       = "Static"
      + ddos_protection_mode    = "VirtualNetworkInherited"
      + fqdn                    = (known after apply)
      + id                      = (known after apply)
      + idle_timeout_in_minutes = 4
      + ip_address              = (known after apply)
      + ip_version              = "IPv4"
      + location                = "eastus"
      + name                    = "multi-ip-pip-secondary-3"
      + resource_group_name     = "rg-multi-ip-test"
      + sku                     = "Standard"
      + sku_tier                = "Regional"
      + tags                    = {
          + "environment" = "test"
          + "index"       = "3"
          + "ip_type"     = "secondary"
          + "purpose"     = "multi-ip-vm"
        }
    }

  # module.multi_ip_vm.azurerm_public_ip.secondary[3] will be created
  + resource "azurerm_public_ip" "secondary" {
      + allocation_method       = "Static"
      + ddos_protection_mode    = "VirtualNetworkInherited"
      + fqdn                    = (known after apply)
      + id                      = (known after apply)
      + idle_timeout_in_minutes = 4
      + ip_address              = (known after apply)
      + ip_version              = "IPv4"
      + location                = "eastus"
      + name                    = "multi-ip-pip-secondary-4"
      + resource_group_name     = "rg-multi-ip-test"
      + sku                     = "Standard"
      + sku_tier                = "Regional"
      + tags                    = {
          + "environment" = "test"
          + "index"       = "4"
          + "ip_type"     = "secondary"
          + "purpose"     = "multi-ip-vm"
        }
    }

  # module.multi_ip_vm.azurerm_public_ip.secondary[4] will be created
  + resource "azurerm_public_ip" "secondary" {
      + allocation_method       = "Static"
      + ddos_protection_mode    = "VirtualNetworkInherited"
      + fqdn                    = (known after apply)
      + id                      = (known after apply)
      + idle_timeout_in_minutes = 4
      + ip_address              = (known after apply)
      + ip_version              = "IPv4"
      + location                = "eastus"
      + name                    = "multi-ip-pip-secondary-5"
      + resource_group_name     = "rg-multi-ip-test"
      + sku                     = "Standard"
      + sku_tier                = "Regional"
      + tags                    = {
          + "environment" = "test"
          + "index"       = "5"
          + "ip_type"     = "secondary"
          + "purpose"     = "multi-ip-vm"
        }
    }

  # module.multi_ip_vm.azurerm_subnet.main will be created
  + resource "azurerm_subnet" "main" {
      + address_prefixes                               = [
          + "10.0.1.0/24",
        ]
      + default_outbound_access_enabled                = true
      + enforce_private_link_endpoint_network_policies = (known after apply)
      + enforce_private_link_service_network_policies  = (known after apply)
      + id                                             = (known after apply)
      + name                                           = "multi-ip-subnet"
      + private_endpoint_network_policies              = (known after apply)
      + private_endpoint_network_policies_enabled      = (known after apply)
      + private_link_service_network_policies_enabled  = (known after apply)
      + resource_group_name                            = "rg-multi-ip-test"
      + virtual_network_name                           = "multi-ip-vnet"
    }

  # module.multi_ip_vm.azurerm_virtual_network.main will be created
  + resource "azurerm_virtual_network" "main" {
      + address_space       = [
          + "10.0.0.0/16",
        ]
      + dns_servers         = (known after apply)
      + guid                = (known after apply)
      + id                  = (known after apply)
      + location            = "eastus"
      + name                = "multi-ip-vnet"
      + resource_group_name = "rg-multi-ip-test"
      + subnet              = (known after apply)
      + tags                = {
          + "environment" = "test"
          + "purpose"     = "multi-ip-vm"
        }
    }

Plan: 13 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + admin_username              = "azureuser"
  + all_private_ips             = [
      + "10.0.1.100",
      + "10.0.1.101",
      + "10.0.1.102",
      + "10.0.1.103",
      + "10.0.1.104",
      + "10.0.1.105",
    ]
  + all_public_ips              = [
      + (known after apply),
      + (known after apply),
      + (known after apply),
      + (known after apply),
      + (known after apply),
      + (known after apply),
    ]
  + deployment_summary          = {
      + admin_user     = "azureuser"
      + all_public_ips = [
          + (known after apply),
          + (known after apply),
          + (known after apply),
          + (known after apply),
          + (known after apply),
          + (known after apply),
        ]
      + ip_count       = 6
      + location       = "eastus"
      + primary_ip     = (known after apply)
      + resource_group = "rg-multi-ip-test"
      + ssh_command    = (known after apply)
      + vm_name        = "multi-ip-vm"
      + vm_size        = "Standard_L2aos_v4"
    }
  + ip_count                    = 6
  + ip_mapping                  = {
      + "10.0.1.100" = (known after apply)
      + "10.0.1.101" = (known after apply)
      + "10.0.1.102" = (known after apply)
      + "10.0.1.103" = (known after apply)
      + "10.0.1.104" = (known after apply)
      + "10.0.1.105" = (known after apply)
    }
  + location                    = "eastus"
  + network_interface_id        = (known after apply)
  + network_interface_name      = "multi-ip-nic"
  + network_security_group_id   = (known after apply)
  + network_security_group_name = "multi-ip-nsg"
  + primary_public_ip           = (known after apply)
  + public_ip_ids               = [
      + (known after apply),
      + (known after apply),
      + (known after apply),
      + (known after apply),
      + (known after apply),
      + (known after apply),
    ]
  + resource_group_name         = "rg-multi-ip-test"
  + secondary_private_ips       = [
      + "10.0.1.101",
      + "10.0.1.102",
      + "10.0.1.103",
      + "10.0.1.104",
      + "10.0.1.105",
    ]
  + secondary_public_ips        = [
      + (known after apply),
      + (known after apply),
      + (known after apply),
      + (known after apply),
      + (known after apply),
    ]
  + ssh_connection_string       = (known after apply)
  + ssh_connection_strings      = [
      + (known after apply),
      + (known after apply),
      + (known after apply),
      + (known after apply),
      + (known after apply),
      + (known after apply),
    ]
  + subnet_id                   = (known after apply)
  + subnet_name                 = "multi-ip-subnet"
  + vm_id                       = (known after apply)
  + vm_name                     = "multi-ip-vm"
  + vm_size                     = "Standard_L2aos_v4"
  + vnet_id                     = (known after apply)
  + vnet_name                   = "multi-ip-vnet"

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.main: Creating...
azurerm_resource_group.main: Still creating... [00m10s elapsed]
azurerm_resource_group.main: Creation complete after 12s [id=/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test]
module.multi_ip_vm.azurerm_public_ip.secondary[1]: Creating...
module.multi_ip_vm.azurerm_public_ip.primary: Creating...
module.multi_ip_vm.azurerm_public_ip.secondary[4]: Creating...
module.multi_ip_vm.azurerm_virtual_network.main: Creating...
module.multi_ip_vm.azurerm_public_ip.secondary[3]: Creating...
module.multi_ip_vm.azurerm_public_ip.secondary[0]: Creating...
module.multi_ip_vm.azurerm_public_ip.secondary[2]: Creating...
module.multi_ip_vm.azurerm_network_security_group.main: Creating...
module.multi_ip_vm.azurerm_public_ip.secondary[1]: Creation complete after 3s [id=/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/publicIPAddresses/multi-ip-pip-secondary-2]
module.multi_ip_vm.azurerm_public_ip.secondary[3]: Creation complete after 3s [id=/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/publicIPAddresses/multi-ip-pip-secondary-4]
module.multi_ip_vm.azurerm_public_ip.secondary[2]: Creation complete after 4s [id=/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/publicIPAddresses/multi-ip-pip-secondary-3]
module.multi_ip_vm.azurerm_public_ip.secondary[0]: Creation complete after 4s [id=/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/publicIPAddresses/multi-ip-pip-secondary-1]
module.multi_ip_vm.azurerm_public_ip.primary: Creation complete after 4s [id=/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/publicIPAddresses/multi-ip-pip-primary]
module.multi_ip_vm.azurerm_public_ip.secondary[4]: Creation complete after 4s [id=/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/publicIPAddresses/multi-ip-pip-secondary-5]
module.multi_ip_vm.azurerm_network_security_group.main: Creation complete after 4s [id=/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/networkSecurityGroups/multi-ip-nsg]
module.multi_ip_vm.azurerm_virtual_network.main: Creation complete after 7s [id=/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/virtualNetworks/multi-ip-vnet]
module.multi_ip_vm.azurerm_subnet.main: Creating...
module.multi_ip_vm.azurerm_subnet.main: Creation complete after 6s [id=/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/virtualNetworks/multi-ip-vnet/subnets/multi-ip-subnet]
module.multi_ip_vm.azurerm_network_interface.main: Creating...
module.multi_ip_vm.azurerm_network_interface.main: Creation complete after 3s [id=/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/networkInterfaces/multi-ip-nic]
module.multi_ip_vm.azurerm_network_interface_security_group_association.main: Creating...
module.multi_ip_vm.azurerm_linux_virtual_machine.main: Creating...
module.multi_ip_vm.azurerm_network_interface_security_group_association.main: Creation complete after 4s [id=/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/networkInterfaces/multi-ip-nic|/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/networkSecurityGroups/multi-ip-nsg]
module.multi_ip_vm.azurerm_linux_virtual_machine.main: Still creating... [00m10s elapsed]
module.multi_ip_vm.azurerm_linux_virtual_machine.main: Still creating... [00m20s elapsed]
module.multi_ip_vm.azurerm_linux_virtual_machine.main: Still creating... [00m30s elapsed]
module.multi_ip_vm.azurerm_linux_virtual_machine.main: Still creating... [00m40s elapsed]
module.multi_ip_vm.azurerm_linux_virtual_machine.main: Still creating... [00m50s elapsed]
module.multi_ip_vm.azurerm_linux_virtual_machine.main: Still creating... [01m00s elapsed]
module.multi_ip_vm.azurerm_linux_virtual_machine.main: Still creating... [01m10s elapsed]
module.multi_ip_vm.azurerm_linux_virtual_machine.main: Still creating... [01m20s elapsed]
module.multi_ip_vm.azurerm_linux_virtual_machine.main: Creation complete after 1m22s [id=/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Compute/virtualMachines/multi-ip-vm]

Apply complete! Resources: 13 added, 0 changed, 0 destroyed.                                                                                                                                           

Outputs:                                                                                                                                                                                               
                                                                                                                                                                                                       
admin_username = "azureuser"                                                                                                                                                                           
all_private_ips = [
  "10.0.1.100",
  "10.0.1.101",
  "10.0.1.102",
  "10.0.1.103",
  "10.0.1.104",
  "10.0.1.105",
]
all_public_ips = [
  "172.190.26.132",
  "4.227.235.90",
  "20.172.249.69",
  "52.226.65.147",
  "13.92.94.192",
  "172.190.190.210",
]
deployment_summary = {
  "admin_user" = "azureuser"
  "all_public_ips" = [
    "172.190.26.132",
    "4.227.235.90",
    "20.172.249.69",
    "52.226.65.147",
    "13.92.94.192",
    "172.190.190.210",
  ]
  "ip_count" = 6
  "location" = "eastus"
  "primary_ip" = "172.190.26.132"
  "resource_group" = "rg-multi-ip-test"
  "ssh_command" = "ssh azureuser@172.190.26.132"
  "vm_name" = "multi-ip-vm"
  "vm_size" = "Standard_L2aos_v4"
}
ip_count = 6
ip_mapping = {
  "10.0.1.100" = "172.190.26.132"
  "10.0.1.101" = "4.227.235.90"
  "10.0.1.102" = "20.172.249.69"
  "10.0.1.103" = "52.226.65.147"
  "10.0.1.104" = "13.92.94.192"
  "10.0.1.105" = "172.190.190.210"
}
location = "eastus"
network_interface_id = "/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/networkInterfaces/multi-ip-nic"
network_interface_name = "multi-ip-nic"
network_security_group_id = "/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/networkSecurityGroups/multi-ip-nsg"
network_security_group_name = "multi-ip-nsg"
primary_public_ip = "172.190.26.132"
public_ip_ids = [
  "/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/publicIPAddresses/multi-ip-pip-primary",
  "/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/publicIPAddresses/multi-ip-pip-secondary-1",
  "/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/publicIPAddresses/multi-ip-pip-secondary-2",
  "/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/publicIPAddresses/multi-ip-pip-secondary-3",
  "/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/publicIPAddresses/multi-ip-pip-secondary-4",
  "/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/publicIPAddresses/multi-ip-pip-secondary-5",
]
resource_group_name = "rg-multi-ip-test"
secondary_private_ips = [
  "10.0.1.101",
  "10.0.1.102",
  "10.0.1.103",
  "10.0.1.104",
  "10.0.1.105",
]
secondary_public_ips = [
  "4.227.235.90",
  "20.172.249.69",
  "52.226.65.147",
  "13.92.94.192",
  "172.190.190.210",
]
ssh_connection_string = "ssh azureuser@172.190.26.132"
ssh_connection_strings = [
  "ssh azureuser@172.190.26.132",
  "ssh azureuser@4.227.235.90",
  "ssh azureuser@20.172.249.69",
  "ssh azureuser@52.226.65.147",
  "ssh azureuser@13.92.94.192",
  "ssh azureuser@172.190.190.210",
]
subnet_id = "/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/virtualNetworks/multi-ip-vnet/subnets/multi-ip-subnet"
subnet_name = "multi-ip-subnet"
vm_id = "/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Compute/virtualMachines/multi-ip-vm"
vm_name = "multi-ip-vm"
vm_size = "Standard_L2aos_v4"
vnet_id = "/subscriptions/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX/resourceGroups/rg-multi-ip-test/providers/Microsoft.Network/virtualNetworks/multi-ip-vnet"
vnet_name = "multi-ip-vnet"
```

### Ansible Playbook Log

```terminaloutput
(.venv) zakhar@archlinux ~/D/T/azure_devops
> ansible-playbook ansible/playbook.yml --extra-vars "verification_script_path=verification.sh"
[WARNING]: No inventory was parsed, only implicit localhost is available
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit localhost does not match 'all'

PLAY [Fetch VM Network Configuration from Azure] ******************************************************************************************************************************************************

TASK [Get Azure VMs with multi-ip-vm tag] *************************************************************************************************************************************************************
ok: [localhost]

TASK [Show discovered VMs] ****************************************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "Found 1 VM(s) with multi-ip-vm tag"
}

TASK [Fail if no VMs found] ***************************************************************************************************************************************************************************
skipping: [localhost]

TASK [Extract resource group and NIC name for each VM] ************************************************************************************************************************************************
ok: [localhost] => (item=multi-ip-vm)

TASK [Get network interface details for each VM] ******************************************************************************************************************************************************
ok: [localhost] => (item=multi-ip-vm)

TASK [Get all public IP addresses in resource group] **************************************************************************************************************************************************
ok: [localhost]

TASK [Build complete IP mappings for each VM] *********************************************************************************************************************************************************
ok: [localhost] => (item=multi-ip-vm)

TASK [Build IP mappings list for each VM] *************************************************************************************************************************************************************
ok: [localhost] => (item=multi-ip-vm)

TASK [Process and add VMs to inventory with IP mappings] **********************************************************************************************************************************************
changed: [localhost] => (item=multi-ip-vm)

TASK [Display discovered VMs and their IPs] ***********************************************************************************************************************************************************
ok: [localhost] => {
    "msg": "VMs discovered and added to inventory:\n- multi-ip-vm (172.190.26.132)\n  IPs: [{'private_ip': '10.0.1.100', 'public_ip': '172.190.26.132', 'is_primary': True}, {'private_ip': '10.0.1.101', 'public_ip': '4.227.235.90', 'is_primary': False}, {'private_ip': '10.0.1.102', 'public_ip': '20.172.249.69', 'is_primary': False}, {'private_ip': '10.0.1.103', 'public_ip': '52.226.65.147', 'is_primary': False}, {'private_ip': '10.0.1.104', 'public_ip': '13.92.94.192', 'is_primary': False}, {'private_ip': '10.0.1.105', 'public_ip': '172.190.190.210', 'is_primary': False}]\n"                 
}

PLAY [Configure Multi-IP Networking with Policy-Based Routing] ****************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************
ok: [172.190.26.132]

TASK [Display target host information] ****************************************************************************************************************************************************************
ok: [172.190.26.132] => {
    "msg": [
        "Configuring host: multi-ip-vm",
        "Resource group: RG-MULTI-IP-TEST",
        "Ansible user: azureuser",
        "Number of IPs to configure: 6"
    ]
}

TASK [Wait for SSH to be available] *******************************************************************************************************************************************************************
ok: [172.190.26.132]

TASK [Gather network facts] ***************************************************************************************************************************************************************************
ok: [172.190.26.132]

TASK [Display current network interfaces] *************************************************************************************************************************************************************
ok: [172.190.26.132] => {
    "msg": [
        "lo",
        "eth0"
    ]
}

TASK [multi_ip_networking : Display IP mappings to be configured] *************************************************************************************************************************************
ok: [172.190.26.132] => {
    "msg": "Configuring 6 IP addresses on eth0"
}

TASK [multi_ip_networking : Ensure iproute2 is installed] *********************************************************************************************************************************************
ok: [172.190.26.132]

TASK [multi_ip_networking : Get current IP addresses on interface] ************************************************************************************************************************************
ok: [172.190.26.132]

TASK [multi_ip_networking : Display current IP configuration] *****************************************************************************************************************************************
ok: [172.190.26.132] => {
    "ip_addr_output.stdout_lines": [
        "2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000",
        "    link/ether 7c:1e:52:18:e1:d1 brd ff:ff:ff:ff:ff:ff",
        "    inet 10.0.1.101/24 brd 10.0.1.255 scope global eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.102/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.103/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.104/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.105/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.100/24 metric 100 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet6 fe80::7e1e:52ff:fe18:e1d1/64 scope link ",
        "       valid_lft forever preferred_lft forever"
    ]
}

TASK [multi_ip_networking : Configure IP aliases on the network interface] ****************************************************************************************************************************
skipping: [172.190.26.132] => (item={'private_ip': '10.0.1.100', 'public_ip': '172.190.26.132', 'is_primary': True}) 
skipping: [172.190.26.132] => (item={'private_ip': '10.0.1.101', 'public_ip': '4.227.235.90', 'is_primary': False}) 
skipping: [172.190.26.132] => (item={'private_ip': '10.0.1.102', 'public_ip': '20.172.249.69', 'is_primary': False}) 
skipping: [172.190.26.132] => (item={'private_ip': '10.0.1.103', 'public_ip': '52.226.65.147', 'is_primary': False}) 
skipping: [172.190.26.132] => (item={'private_ip': '10.0.1.104', 'public_ip': '13.92.94.192', 'is_primary': False}) 
skipping: [172.190.26.132] => (item={'private_ip': '10.0.1.105', 'public_ip': '172.190.190.210', 'is_primary': False}) 
skipping: [172.190.26.132]

TASK [multi_ip_networking : Backup existing rt_tables file] *******************************************************************************************************************************************
changed: [172.190.26.132]

TASK [multi_ip_networking : Add custom routing tables to rt_tables] ***********************************************************************************************************************************
skipping: [172.190.26.132] => (item={'private_ip': '10.0.1.100', 'public_ip': '172.190.26.132', 'is_primary': True}) 
changed: [172.190.26.132] => (item={'private_ip': '10.0.1.101', 'public_ip': '4.227.235.90', 'is_primary': False})
changed: [172.190.26.132] => (item={'private_ip': '10.0.1.102', 'public_ip': '20.172.249.69', 'is_primary': False})
changed: [172.190.26.132] => (item={'private_ip': '10.0.1.103', 'public_ip': '52.226.65.147', 'is_primary': False})
changed: [172.190.26.132] => (item={'private_ip': '10.0.1.104', 'public_ip': '13.92.94.192', 'is_primary': False})
changed: [172.190.26.132] => (item={'private_ip': '10.0.1.105', 'public_ip': '172.190.190.210', 'is_primary': False})

TASK [multi_ip_networking : Create routing configuration script] **************************************************************************************************************************************
changed: [172.190.26.132]

TASK [multi_ip_networking : Apply routing configuration] **********************************************************************************************************************************************
ok: [172.190.26.132]

TASK [multi_ip_networking : Create systemd service for persistent routing] ****************************************************************************************************************************
changed: [172.190.26.132]

TASK [multi_ip_networking : Enable multi-ip-routing service] ******************************************************************************************************************************************
changed: [172.190.26.132]

TASK [multi_ip_networking : Verify IP addresses are configured] ***************************************************************************************************************************************
ok: [172.190.26.132]

TASK [multi_ip_networking : Display final IP configuration] *******************************************************************************************************************************************
ok: [172.190.26.132] => {
    "final_ip_config.stdout_lines": [
        "2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000",
        "    link/ether 7c:1e:52:18:e1:d1 brd ff:ff:ff:ff:ff:ff",
        "    inet 10.0.1.101/24 brd 10.0.1.255 scope global eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.102/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.103/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.104/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.105/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.100/24 metric 100 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet6 fe80::7e1e:52ff:fe18:e1d1/64 scope link ",
        "       valid_lft forever preferred_lft forever"
    ]
}

TASK [multi_ip_networking : Verify IP rules are configured] *******************************************************************************************************************************************
ok: [172.190.26.132]

TASK [multi_ip_networking : Display IP rules] *********************************************************************************************************************************************************
ok: [172.190.26.132] => {
    "ip_rules.stdout_lines": [
        "0:\tfrom all lookup local",
        "32761:\tfrom 10.0.1.105 lookup rt_table_10_0_1_105",
        "32762:\tfrom 10.0.1.104 lookup rt_table_10_0_1_104",
        "32763:\tfrom 10.0.1.103 lookup rt_table_10_0_1_103",
        "32764:\tfrom 10.0.1.102 lookup rt_table_10_0_1_102",
        "32765:\tfrom 10.0.1.101 lookup rt_table_10_0_1_101",
        "32766:\tfrom all lookup main",
        "32767:\tfrom all lookup default"
    ]
}

TASK [multi_ip_networking : Verify routing tables] ****************************************************************************************************************************************************
skipping: [172.190.26.132] => (item={'private_ip': '10.0.1.100', 'public_ip': '172.190.26.132', 'is_primary': True}) 
ok: [172.190.26.132] => (item={'private_ip': '10.0.1.101', 'public_ip': '4.227.235.90', 'is_primary': False})
ok: [172.190.26.132] => (item={'private_ip': '10.0.1.102', 'public_ip': '20.172.249.69', 'is_primary': False})
ok: [172.190.26.132] => (item={'private_ip': '10.0.1.103', 'public_ip': '52.226.65.147', 'is_primary': False})
ok: [172.190.26.132] => (item={'private_ip': '10.0.1.104', 'public_ip': '13.92.94.192', 'is_primary': False})
ok: [172.190.26.132] => (item={'private_ip': '10.0.1.105', 'public_ip': '172.190.190.210', 'is_primary': False})

TASK [multi_ip_networking : Display routing tables] ***************************************************************************************************************************************************
skipping: [172.190.26.132] => (item={'changed': False, 'skipped': True, 'skip_reason': 'Conditional result was False', 'false_condition': 'not item.is_primary | default(false)', 'item': {'private_ip': '10.0.1.100', 'public_ip': '172.190.26.132', 'is_primary': True}, 'ansible_loop_var': 'item'})                                                                                                       
ok: [172.190.26.132] => (item={'changed': False, 'stdout': 'default via 10.0.1.1 dev eth0 ', 'stderr': '', 'rc': 0, 'cmd': ['ip', 'route', 'show', 'table', 'rt_table_10_0_1_101'], 'start': '2025-12-06 15:43:03.112931', 'end': '2025-12-06 15:43:03.115883', 'delta': '0:00:00.002952', 'msg': '', 'invocation': {'module_args': {'_raw_params': 'ip route show table rt_table_10_0_1_101', '_uses_shell': False, 'expand_argument_vars': True, 'stdin_add_newline': True, 'strip_empty_ends': True, 'cmd': None, 'argv': None, 'chdir': None, 'executable': None, 'creates': None, 'removes': None, 'stdin': None}}, 'stdout_lines': ['default via 10.0.1.1 dev eth0 '], 'stderr_lines': [], 'failed': False, 'item': {'private_ip': '10.0.1.101', 'public_ip': '4.227.235.90', 'is_primary': False}, 'ansible_loop_var': 'item'}) => {                                                                                                                                                                                        
    "msg": "Table for 10.0.1.101: default via 10.0.1.1 dev eth0 "
}
ok: [172.190.26.132] => (item={'changed': False, 'stdout': 'default via 10.0.1.1 dev eth0 ', 'stderr': '', 'rc': 0, 'cmd': ['ip', 'route', 'show', 'table', 'rt_table_10_0_1_102'], 'start': '2025-12-06 15:43:07.625293', 'end': '2025-12-06 15:43:07.628259', 'delta': '0:00:00.002966', 'msg': '', 'invocation': {'module_args': {'_raw_params': 'ip route show table rt_table_10_0_1_102', '_uses_shell': False, 'expand_argument_vars': True, 'stdin_add_newline': True, 'strip_empty_ends': True, 'cmd': None, 'argv': None, 'chdir': None, 'executable': None, 'creates': None, 'removes': None, 'stdin': None}}, 'stdout_lines': ['default via 10.0.1.1 dev eth0 '], 'stderr_lines': [], 'failed': False, 'item': {'private_ip': '10.0.1.102', 'public_ip': '20.172.249.69', 'is_primary': False}, 'ansible_loop_var': 'item'}) => {                                                                                                                                                                                       
    "msg": "Table for 10.0.1.102: default via 10.0.1.1 dev eth0 "
}
ok: [172.190.26.132] => (item={'changed': False, 'stdout': 'default via 10.0.1.1 dev eth0 ', 'stderr': '', 'rc': 0, 'cmd': ['ip', 'route', 'show', 'table', 'rt_table_10_0_1_103'], 'start': '2025-12-06 15:43:12.021642', 'end': '2025-12-06 15:43:12.024597', 'delta': '0:00:00.002955', 'msg': '', 'invocation': {'module_args': {'_raw_params': 'ip route show table rt_table_10_0_1_103', '_uses_shell': False, 'expand_argument_vars': True, 'stdin_add_newline': True, 'strip_empty_ends': True, 'cmd': None, 'argv': None, 'chdir': None, 'executable': None, 'creates': None, 'removes': None, 'stdin': None}}, 'stdout_lines': ['default via 10.0.1.1 dev eth0 '], 'stderr_lines': [], 'failed': False, 'item': {'private_ip': '10.0.1.103', 'public_ip': '52.226.65.147', 'is_primary': False}, 'ansible_loop_var': 'item'}) => {                                                                                                                                                                                       
    "msg": "Table for 10.0.1.103: default via 10.0.1.1 dev eth0 "
}
ok: [172.190.26.132] => (item={'changed': False, 'stdout': 'default via 10.0.1.1 dev eth0 ', 'stderr': '', 'rc': 0, 'cmd': ['ip', 'route', 'show', 'table', 'rt_table_10_0_1_104'], 'start': '2025-12-06 15:43:16.524941', 'end': '2025-12-06 15:43:16.527849', 'delta': '0:00:00.002908', 'msg': '', 'invocation': {'module_args': {'_raw_params': 'ip route show table rt_table_10_0_1_104', '_uses_shell': False, 'expand_argument_vars': True, 'stdin_add_newline': True, 'strip_empty_ends': True, 'cmd': None, 'argv': None, 'chdir': None, 'executable': None, 'creates': None, 'removes': None, 'stdin': None}}, 'stdout_lines': ['default via 10.0.1.1 dev eth0 '], 'stderr_lines': [], 'failed': False, 'item': {'private_ip': '10.0.1.104', 'public_ip': '13.92.94.192', 'is_primary': False}, 'ansible_loop_var': 'item'}) => {                                                                                                                                                                                        
    "msg": "Table for 10.0.1.104: default via 10.0.1.1 dev eth0 "
}
ok: [172.190.26.132] => (item={'changed': False, 'stdout': 'default via 10.0.1.1 dev eth0 ', 'stderr': '', 'rc': 0, 'cmd': ['ip', 'route', 'show', 'table', 'rt_table_10_0_1_105'], 'start': '2025-12-06 15:43:20.826989', 'end': '2025-12-06 15:43:20.829954', 'delta': '0:00:00.002965', 'msg': '', 'invocation': {'module_args': {'_raw_params': 'ip route show table rt_table_10_0_1_105', '_uses_shell': False, 'expand_argument_vars': True, 'stdin_add_newline': True, 'strip_empty_ends': True, 'cmd': None, 'argv': None, 'chdir': None, 'executable': None, 'creates': None, 'removes': None, 'stdin': None}}, 'stdout_lines': ['default via 10.0.1.1 dev eth0 '], 'stderr_lines': [], 'failed': False, 'item': {'private_ip': '10.0.1.105', 'public_ip': '172.190.190.210', 'is_primary': False}, 'ansible_loop_var': 'item'}) => {                                                                                                                                                                                     
    "msg": "Table for 10.0.1.105: default via 10.0.1.1 dev eth0 "
}

RUNNING HANDLER [multi_ip_networking : restart multi-ip-routing service] ******************************************************************************************************************************
changed: [172.190.26.132]

TASK [Final verification - show all IP addresses] *****************************************************************************************************************************************************
ok: [172.190.26.132]

TASK [Display all IP addresses] ***********************************************************************************************************************************************************************
ok: [172.190.26.132] => {
    "all_ips.stdout_lines": [
        "1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000",
        "    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00",
        "    inet 127.0.0.1/8 scope host lo",
        "       valid_lft forever preferred_lft forever",
        "    inet6 ::1/128 scope host ",
        "       valid_lft forever preferred_lft forever",
        "2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000",
        "    link/ether 7c:1e:52:18:e1:d1 brd ff:ff:ff:ff:ff:ff",
        "    inet 10.0.1.101/24 brd 10.0.1.255 scope global eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.102/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.103/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.104/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.105/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.100/24 metric 100 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet6 fe80::7e1e:52ff:fe18:e1d1/64 scope link ",
        "       valid_lft forever preferred_lft forever"
    ]
}

TASK [Final verification - show all routing rules] ****************************************************************************************************************************************************
ok: [172.190.26.132]

TASK [Display all routing rules] **********************************************************************************************************************************************************************
ok: [172.190.26.132] => {
    "all_rules.stdout_lines": [
        "0:\tfrom all lookup local",
        "32761:\tfrom 10.0.1.105 lookup rt_table_10_0_1_105",
        "32762:\tfrom 10.0.1.104 lookup rt_table_10_0_1_104",
        "32763:\tfrom 10.0.1.103 lookup rt_table_10_0_1_103",
        "32764:\tfrom 10.0.1.102 lookup rt_table_10_0_1_102",
        "32765:\tfrom 10.0.1.101 lookup rt_table_10_0_1_101",
        "32766:\tfrom all lookup main",
        "32767:\tfrom all lookup default"
    ]
}

TASK [Create IP mappings file on remote VM] ***********************************************************************************************************************************************************
changed: [172.190.26.132]

TASK [Copy verification script to remote VM] **********************************************************************************************************************************************************
changed: [172.190.26.132]

TASK [Install jq] *************************************************************************************************************************************************************************************
changed: [172.190.26.132]

TASK [Execute verification script on remote VM] *******************************************************************************************************************************************************
ok: [172.190.26.132]

TASK [Display verification script results] ************************************************************************************************************************************************************
ok: [172.190.26.132] => {
    "verification_result.stdout_lines": [
        "[2025-12-06 15:44:15] Starting network verification script...",
        "[2025-12-06 15:44:15] Verifying IP rules...",
        "[2025-12-06 15:44:15] SUCCESS: IP rules are present.",
        "0:\tfrom all lookup local",
        "32761:\tfrom 10.0.1.105 lookup rt_table_10_0_1_105",
        "32762:\tfrom 10.0.1.104 lookup rt_table_10_0_1_104",
        "32763:\tfrom 10.0.1.103 lookup rt_table_10_0_1_103",
        "32764:\tfrom 10.0.1.102 lookup rt_table_10_0_1_102",
        "32765:\tfrom 10.0.1.101 lookup rt_table_10_0_1_101",
        "32766:\tfrom all lookup main",
        "32767:\tfrom all lookup default",
        "[2025-12-06 15:44:15] Verifying IP addresses...",
        "[2025-12-06 15:44:15] SUCCESS: IP addresses are configured on eth0.",
        "2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000",
        "    inet 10.0.1.101/24 brd 10.0.1.255 scope global eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.102/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.103/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.104/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.105/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.100/24 metric 100 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "[2025-12-06 15:44:15] Testing outbound connectivity for each private IP...",
        "[2025-12-06 15:44:15] Found private IPs: 10.0.1.100 10.0.1.101 10.0.1.102 10.0.1.103 10.0.1.104 10.0.1.105",
        "[2025-12-06 15:44:15] Testing from private IP: 10.0.1.100...",
        "[2025-12-06 15:44:15] SUCCESS: Outbound request from 10.0.1.100 used public IP: 172.190.26.132",
        "[2025-12-06 15:44:15] Testing from private IP: 10.0.1.101...",
        "[2025-12-06 15:44:15] SUCCESS: Outbound request from 10.0.1.101 used public IP: 4.227.235.90",
        "[2025-12-06 15:44:15] Testing from private IP: 10.0.1.102...",
        "[2025-12-06 15:44:15] SUCCESS: Outbound request from 10.0.1.102 used public IP: 20.172.249.69",
        "[2025-12-06 15:44:15] Testing from private IP: 10.0.1.103...",
        "[2025-12-06 15:44:15] SUCCESS: Outbound request from 10.0.1.103 used public IP: 52.226.65.147",
        "[2025-12-06 15:44:15] Testing from private IP: 10.0.1.104...",
        "[2025-12-06 15:44:15] SUCCESS: Outbound request from 10.0.1.104 used public IP: 13.92.94.192",
        "[2025-12-06 15:44:15] Testing from private IP: 10.0.1.105...",
        "[2025-12-06 15:44:15] SUCCESS: Outbound request from 10.0.1.105 used public IP: 172.190.190.210",
        "[2025-12-06 15:44:15] ",
        "[2025-12-06 15:44:15] Final Result: All public IPs are functional.",
        "[2025-12-06 15:44:15] Verification complete."
    ]
}

TASK [Check if systemd service is enabled] ************************************************************************************************************************************************************
ok: [172.190.26.132]

TASK [Display service status] *************************************************************************************************************************************************************************
ok: [172.190.26.132] => {
    "msg": [
        "Service enabled: loaded",
        "Service active: active"
    ]
}

TASK [Configuration complete message] *****************************************************************************************************************************************************************
ok: [172.190.26.132] => {
    "msg": "Multi-IP networking configuration complete"
}

PLAY RECAP ********************************************************************************************************************************************************************************************
172.190.26.132             : ok=34   changed=9    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
localhost                  : ok=9    changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   

```

### Verification Script Log (from Ansible Output)

```terminaloutput
TASK [Create IP mappings file on remote VM] ***********************************************************************************************************************************************************
changed: [172.190.26.132]

TASK [Copy verification script to remote VM] **********************************************************************************************************************************************************
changed: [172.190.26.132]

TASK [Install jq] *************************************************************************************************************************************************************************************
changed: [172.190.26.132]

TASK [Execute verification script on remote VM] *******************************************************************************************************************************************************
ok: [172.190.26.132]

TASK [Display verification script results] ************************************************************************************************************************************************************
ok: [172.190.26.132] => {
    "verification_result.stdout_lines": [
        "[2025-12-06 15:44:15] Starting network verification script...",
        "[2025-12-06 15:44:15] Verifying IP rules...",
        "[2025-12-06 15:44:15] SUCCESS: IP rules are present.",
        "0:\tfrom all lookup local",
        "32761:\tfrom 10.0.1.105 lookup rt_table_10_0_1_105",
        "32762:\tfrom 10.0.1.104 lookup rt_table_10_0_1_104",
        "32763:\tfrom 10.0.1.103 lookup rt_table_10_0_1_103",
        "32764:\tfrom 10.0.1.102 lookup rt_table_10_0_1_102",
        "32765:\tfrom 10.0.1.101 lookup rt_table_10_0_1_101",
        "32766:\tfrom all lookup main",
        "32767:\tfrom all lookup default",
        "[2025-12-06 15:44:15] Verifying IP addresses...",
        "[2025-12-06 15:44:15] SUCCESS: IP addresses are configured on eth0.",
        "2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000",
        "    inet 10.0.1.101/24 brd 10.0.1.255 scope global eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.102/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.103/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.104/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.105/24 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "    inet 10.0.1.100/24 metric 100 brd 10.0.1.255 scope global secondary eth0",
        "       valid_lft forever preferred_lft forever",
        "[2025-12-06 15:44:15] Testing outbound connectivity for each private IP...",
        "[2025-12-06 15:44:15] Found private IPs: 10.0.1.100 10.0.1.101 10.0.1.102 10.0.1.103 10.0.1.104 10.0.1.105",
        "[2025-12-06 15:44:15] Testing from private IP: 10.0.1.100...",
        "[2025-12-06 15:44:15] SUCCESS: Outbound request from 10.0.1.100 used public IP: 172.190.26.132",
        "[2025-12-06 15:44:15] Testing from private IP: 10.0.1.101...",
        "[2025-12-06 15:44:15] SUCCESS: Outbound request from 10.0.1.101 used public IP: 4.227.235.90",
        "[2025-12-06 15:44:15] Testing from private IP: 10.0.1.102...",
        "[2025-12-06 15:44:15] SUCCESS: Outbound request from 10.0.1.102 used public IP: 20.172.249.69",
        "[2025-12-06 15:44:15] Testing from private IP: 10.0.1.103...",
        "[2025-12-06 15:44:15] SUCCESS: Outbound request from 10.0.1.103 used public IP: 52.226.65.147",
        "[2025-12-06 15:44:15] Testing from private IP: 10.0.1.104...",
        "[2025-12-06 15:44:15] SUCCESS: Outbound request from 10.0.1.104 used public IP: 13.92.94.192",
        "[2025-12-06 15:44:15] Testing from private IP: 10.0.1.105...",
        "[2025-12-06 15:44:15] SUCCESS: Outbound request from 10.0.1.105 used public IP: 172.190.190.210",
        "[2025-12-06 15:44:15] ",
        "[2025-12-06 15:44:15] Final Result: All public IPs are functional.",
        "[2025-12-06 15:44:15] Verification complete."
    ]
}
```
