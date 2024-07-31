provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "insecure_rg" {
  name     = "insecure-rg"
  location = "East US"
}

resource "azurerm_storage_account" "insecure_sa" {
  name                     = "insecurestorageaccount"
  resource_group_name      = azurerm_resource_group.insecure_rg.name
  location                 = azurerm_resource_group.insecure_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Insecure: No encryption settings specified, defaults to unencrypted
}

resource "azurerm_virtual_network" "insecure_vnet" {
  name                = "insecure-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name
}

resource "azurerm_subnet" "insecure_subnet" {
  name                 = "insecure-subnet"
  resource_group_name  = azurerm_resource_group.insecure_rg.name
  virtual_network_name = azurerm_virtual_network.insecure_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "insecure_nsg" {
  name                = "insecure-nsg"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name

  security_rule {
    name                       = "allow_insecure"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "insecure_nic" {
  name                = "insecure-nic"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.insecure_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "insecure_pip" {
  name                = "insecure-pip"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface_security_group_association" "insecure_nic_nsg" {
  network_interface_id      = azurerm_network_interface.insecure_nic.id
  network_security_group_id = azurerm_network_security_group.insecure_nsg.id
}

resource "azurerm_linux_virtual_machine" "insecure_vm" {
  name                = "insecure-vm"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name
  network_interface_ids = [
    azurerm_network_interface.insecure_nic.id,
  ]
  size               = "Standard_B1s"
  admin_username     = "adminuser"

  admin_password     = "WeakPassword123!"  # Insecure: Weak password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"  # Insecure: Standard_LRS does not offer high availability
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name  = "hostname"
  disable_password_authentication = false  # Insecure: Allows password authentication

  # Insecure: No monitoring or logging enabled
}

resource "azurerm_sql_server" "insecure_sql_server" {
  name                         = "insecure-sql-server"
  resource_group_name          = azurerm_resource_group.insecure_rg.name
  location                     = azurerm_resource_group.insecure_rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "WeakPassword123!"  # Insecure: Weak password

  # Insecure: No advanced security or auditing configurations
}

resource "azurerm_sql_database" "insecure_sql_db" {
  name                = "insecure-sql-db"
  resource_group_name = azurerm_resource_group.insecure_rg.name
  location            = azurerm_resource_group.insecure_rg.location
  server_name         = azurerm_sql_server.insecure_sql_server.name
  sku_name            = "Basic"

  # Insecure: No threat detection or auditing enabled
}

resource "azurerm_app_service_plan" "insecure_asp" {
  name                = "insecure-asp"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name
  sku {
    tier     = "Free"
    size     = "F1"
  }
}

resource "azurerm_app_service" "insecure_app_service" {
  name                = "insecure-app-service"
  location            = azurerm_resource_group.insecure_rg.location
  resource_group_name = azurerm_resource_group.insecure_rg.name
  app_service_plan_id = azurerm_app_service_plan.insecure_asp.id
}
