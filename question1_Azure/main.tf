provider "azurerm" {
  version = "=2.13.0"
  features {}
}

terraform {
    backend "azurerm" {
        azurerm_resource_group = "tstatefile"
        storage_account_name = "teliosstorageaccount"
        container_name = "terraform.tfstate"
    }
}

# Create azure App service

resource "azurerm_resource_group" "teliosRG" {
  name     = "teliosRG"
  location = ""Central US"
}

resource "azurerm_app_service_plan" "serviceplan" {
  name                = "telios-appserviceplan"
  location            = azurerm_resource_group.teliosRG.location
  resource_group_name = azurerm_resource_group.teliosRG.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "telios_App" {
  name                = "telios-app-service"
  location            = azurerm_resource_group.teliosRG.location
  resource_group_name = azurerm_resource_group.teliosRG.name
  app_service_plan_id = azurerm_app_service_plan.serviceplan.id

}


# Create ubuntu VM


# Create virtual network
resource "azurerm_virtual_network" "teliosterraformnetwork" {
    name                = "teliosVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "Central US"
  resource_group_name = azurerm_resource_group.teliosRG.name

}

# Create subnet
resource "azurerm_subnet" "teliosterraformsubnet" {
    name                 = "teliosSubnet"
    resource_group_name = azurerm_resource_group.teliosRG.name
    virtual_network_name = azurerm_virtual_network.teliosterraformnetwork.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "teliosterraformpublicip" {
    name                         = "teliosPublicIP"
    location                     = "Central US"
    resource_group_name          =   azurerm_resource_group.teliosRG.name
    allocation_method            = "Dynamic"

}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "teliosterraformnsg" {
    name                = "teliosNetworkSecurityGroup"
    location            = "Central US"
    resource_group_name = azurerm_resource_group.teliosRG.name
    
    security_rule {
        name                       = "SSH"
        priority                   = "100"
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

}

# Create network interface
resource "azurerm_network_interface" "teliosterraformnic" {
    name                      = "teliosNIC"
    location                  = "Central US"
    resource_group_name       = azurerm_resource_group.teliosRG.name

    ip_configuration {
        name                          = "teliosNicConfiguration"
        subnet_id                     = azurerm_subnet.teliosterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.teliosterraformpublicip.id
    }

}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "teliosconnsg" {
    network_interface_id      = azurerm_network_interface.teliosterraformnic.id
    network_security_group_id = azurerm_network_security_group.teliosterraformnsg.id
}

# Create (and display) an SSH key
resource "tls_private_key" "telios_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { value = "${tls_private_key.telios_ssh.private_key_pem}" }

#Create a load balancer

resource "azurerm_lb_backend_address_pool" "loadbalancer" {
 resource_group_name = azurerm_resource_group.loadbalancer.name
 loadbalancer_id     = azurerm_lb.loadbalancer.id
 name                = "BackEndAddressPool"
}


# Create virtual machine
resource "azurerm_linux_virtual_machine" "teliosvm" {
    name                  = "ubuntudevVM"
    location              = "Central US"
    resource_group_name   = "azurerm_resource_group.teliosRG.name"
    network_interface_ids = [azurerm_network_interface.teliosterraformnic.id]
    size                  = "Standard_DS1_v2"
    loadbalancer_id     = "azurerm_lb.loadbalancer.id"

    os_disk {
        name              = "teliosOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    computer_name  = "teliosprojectvm"
    admin_username = "chidi"
    disable_password_authentication = true
        
    admin_ssh_key {
        username       = "chidi"
        public_key     = tls_private_key.udacity_ssh.public_key_openssh
    }

#Implemet zero downtime

  lifecycle {
    create_before_destroy = true
  }
}




