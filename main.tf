
# --------------------------------------------------
# 1. Resource Group
# --------------------------------------------------

resource "azurerm_resource_group" "sakshi" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Owner      = "Sakshi"
    Assignment = "Terraform-D2-ASS1"
    Purpose    = "Windows-IIS-Lab"
  }
}

# --------------------------------------------------
# 2. Virtual Network
# --------------------------------------------------

resource "azurerm_virtual_network" "sakshi" {
  name                = "vnet-sakshi-d2-ass1"
  address_space       = ["10.20.0.0/16"]
  location            = azurerm_resource_group.sakshi.location
  resource_group_name = azurerm_resource_group.sakshi.name

  tags = {
    Owner = "Sakshi"
  }
}

# --------------------------------------------------
# 3. Subnet
# --------------------------------------------------

resource "azurerm_subnet" "sakshi" {
  name                 = "subnet-sakshi-d2-ass1"
  resource_group_name  = azurerm_resource_group.sakshi.name
  virtual_network_name = azurerm_virtual_network.sakshi.name
  address_prefixes     = ["10.20.1.0/24"]
}

# --------------------------------------------------
# 4. Network Security Group
# --------------------------------------------------

resource "azurerm_network_security_group" "sakshi" {
  name                = "nsg-sakshi-d2-ass1"
  location            = azurerm_resource_group.sakshi.location
  resource_group_name = azurerm_resource_group.sakshi.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Owner = "Sakshi"
  }
}

# --------------------------------------------------
# 5. Public IP
# --------------------------------------------------

resource "azurerm_public_ip" "sakshi" {
  name                = "pip-sakshi-d2-ass1"
  location            = azurerm_resource_group.sakshi.location
  resource_group_name = azurerm_resource_group.sakshi.name

  allocation_method = "Static"
  sku               = "Standard"

  tags = {
    Owner = "Sakshi"
  }
}

# --------------------------------------------------
# 6. Network Interface
# --------------------------------------------------

resource "azurerm_network_interface" "sakshi" {
  name                = "nic-sakshi-d2-ass1"
  location            = azurerm_resource_group.sakshi.location
  resource_group_name = azurerm_resource_group.sakshi.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sakshi.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sakshi.id
  }

  tags = {
    Owner = "Sakshi"
  }
}

# --------------------------------------------------
# 7. Associate NSG with Network Interface
# --------------------------------------------------

resource "azurerm_network_interface_security_group_association" "sakshi" {
  network_interface_id      = azurerm_network_interface.sakshi.id
  network_security_group_id = azurerm_network_security_group.sakshi.id
}

# --------------------------------------------------
# 8. Windows Virtual Machine
# --------------------------------------------------

resource "azurerm_windows_virtual_machine" "sakshi" {
  name                = "sakshi-d2a1-vm"
  computer_name       = "sakshi-d2a1-vm"
  resource_group_name = azurerm_resource_group.sakshi.name
  location            = azurerm_resource_group.sakshi.location
  size                = var.vm_size

  admin_username = var.admin_username
  admin_password = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.sakshi.id
  ]

  provision_vm_agent = true

  os_disk {
    name                 = "osdisk-sakshi-d2-ass1"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }

  tags = {
    Owner      = "Sakshi"
    Assignment = "Terraform-D2-ASS1"
    Purpose    = "IIS-Web-Server"
  }

  # Ensure the NSG association is completed before
  # creating the VM and running the IIS provisioner.
  depends_on = [
    azurerm_network_interface_security_group_association.sakshi
  ]

  # ------------------------------------------------
  # 9. Terraform Provisioner
  # ------------------------------------------------

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]

    command = <<-EOT
      set -e
      echo "Installing IIS on ${self.name} using Azure VM Run Command..."

      az vm run-command invoke \
        --resource-group "${self.resource_group_name}" \
        --name "${self.name}" \
        --command-id RunPowerShellScript \
        --scripts "$(cat '${path.module}/install-iis.ps1')" \
        --output json
    EOT
  }
}

