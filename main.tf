# TF docs for azure https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id # Make sure to set this variable in your variables.tf
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "Temp-app-rg"
  location = "Spain Central"
}

# Create a virtual network
resource "azurerm_virtual_network" "net" {
  name                = "Temp-app-net"
  address_space       = ["10.0.0.0/16"] # Adjust the address space as needed
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a subnet
resource "azurerm_subnet" "subnet" {
  name                 = "Temp-app-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.net.name
  address_prefixes     = ["10.0.1.0/24"] # Adjust the address prefix as needed
}

# Create a security group
resource "azurerm_network_security_group" "sec-group" {
  name                = "Temp-app-sec-group"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a security rule (this is a temporary rule adjust as needed)
# Note: The source_address_prefix should be set to your IP address or a specific range for security purposes.
resource "azurerm_network_security_rule" "sec-rule" {
  name                        = "Temp-app-sec-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["22", "80", "443", "3000"] # SSH, HTTP, HTTPS and Grafana port
  source_address_prefix       = "*"                 # chance for your IP address or only the IPs you want to allow
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.sec-group.name
}

# Associate the security group with the subnet
resource "azurerm_subnet_network_security_group_association" "subnet-sec-group-assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.sec-group.id
}

# Create a public IP address for the NIC
resource "azurerm_public_ip" "VM-pub-ip" {
  name                = "NIC-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create a network interface
resource "azurerm_network_interface" "VM-nic" {
  name                = "Temp-app-VM-NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.VM-pub-ip.id
  }
}

# Create a network interface security group association
resource "azurerm_network_interface_security_group_association" "VM-nic-sec-group-assoc" {
  network_interface_id      = azurerm_network_interface.VM-nic.id
  network_security_group_id = azurerm_network_security_group.sec-group.id
}

# Create a linux virtual machine
resource "azurerm_linux_virtual_machine" "VM" {
  name                = "Temp-app-VM"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s" # Adjust the VM size as needed
  admin_username      = "azureuser"
  admin_password      = var.admin_password # Make sure to set this variable in your variables.tf

  network_interface_ids = [azurerm_network_interface.VM-nic.id]

# set the .env file for the docker compose
  user_data = base64encode( <<EOF
#!/bin/bash

# Install Docker and Docker Compose
sudo apt-get update
sudo apt-get install -y docker.io docker-compose

sleep 30 # wait for docker to be installed

# Clone GitRepo
cd /home/azureuser
sudo apt-get install -y git
git clone https://github.com/bernas12/Cloudmore_assignment
cd Cloudmore_assignment

# set .env file
touch .env # create an empty .env file
echo GF_SECURITY_ADMIN_PASSWORD=${var.GF_SECURITY_ADMIN_PASSWORD} > .env
echo OPENWEATHER_API_KEY=${var.OPENWEATHER_API_KEY} >> .env

# run docker compose
docker-compose up -d
EOF
  )
  
  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.public_key) # Make sure to set this variable in your variables.tf
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}