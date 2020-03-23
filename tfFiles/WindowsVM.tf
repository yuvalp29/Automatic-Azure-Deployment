provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you are using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}

    subscription_id = "${var.subscription_id}"
    client_id = "${var.client_id}"
    client_secret = "${var.client_secret}"
    tenant_id = "${var.tenant_id}"
}

# Refers to a specific resource group
data "azurerm_resource_group" "TechnologyRG" {
  name = "${var.resource_group}"
}

# Refers to a specific virtual network
data "azurerm_virtual_network" "TechnologyNET" {
  name                = "${var.virtual_network}"
  resource_group_name = "${data.azurerm_resource_group.TechnologyRG.name}"
}

# Refers to a specific subnet
data "azurerm_subnet" "TechnologySUBNET" {
  name                 = "${var.subnet}"
  virtual_network_name = "${data.azurerm_virtual_network.TechnologyNET.name}"
  resource_group_name  = "${data.azurerm_resource_group.TechnologyRG.name}"
}

# Creates public IP
resource "azurerm_public_ip" "TechnologyIP" {
  name                = "${var.prefix}PublicIP"
  location            = "${var.location}"
  resource_group_name = "${data.azurerm_resource_group.TechnologyRG.name}"
  allocation_method   = "Static"

  tags = {
    Owner  = "Yuval"
    method = "Terraform"
  }
}

# Creates network security group
resource "azurerm_network_security_group" "TechnologyNSG" {
    name                = "${var.prefix}NSG"
    location            = "${var.location}"
    resource_group_name = "${data.azurerm_resource_group.TechnologyRG.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    
    tags = {
      Owner  = "Yuval"
      method = "Terraform"
    }
}

# Create network interface
resource "azurerm_network_interface" "TechnologyNIC" {
  name                = "${var.prefix}NIC"
  location            = "${var.location}"
  resource_group_name = "${data.azurerm_resource_group.TechnologyRG.name}"

  ip_configuration {
     name                          = "TestConfiguration"
     private_ip_address_allocation = "Dynamic"
     subnet_id                     = "${data.azurerm_subnet.TechnologySUBNET.id}"
     public_ip_address_id          = "${azurerm_public_ip.TechnologyIP.id}"
  }

  tags = {
    Owner  = "Yuval"
    method = "Terraform"
  }
}

# Connects the security group to the network interface
resource "azurerm_network_interface_security_group_association" "ASSOCIATE" {
    network_interface_id      = azurerm_network_interface.TechnologyNIC.id
    network_security_group_id = azurerm_network_security_group.TechnologyNSG.id
}

# Create Ubuntu 16.04 virtual machine
resource "azurerm_virtual_machine" "TechnologyVM" {
  name                  = "${var.vm_name}"
  location              = "${var.location}"
  resource_group_name   = "${data.azurerm_resource_group.TechnologyRG.name}"
  network_interface_ids = [azurerm_network_interface.TechnologyNIC.id]
  vm_size               = "${var.vm_size}"

  # uncomment this line to delete the os disk automatically when deleting the vm
  delete_os_disk_on_termination = true

  # uncomment this line to delete the data disks automatically when deleting the vm
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter-Server-Core-smalldisk"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "readwrite"
    create_option     = "fromimage"
    managed_disk_type = "${var.disk_type}"
  }

  os_profile {
    computer_name  = "terraformvm"
    admin_username = "techadmin"
    admin_password = "Aa123456123456Bb"
  }

  os_profile_windows_config {
  }

  tags = {
    Owner  = "Yuval"
    method = "Terraform"
  }
}