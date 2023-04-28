# Resource 1 : Create a resource group
resource "azurerm_resource_group" "rafi-rg" {
  name     = "ansible-rg"
  location = "Central India"
}

# Resource-2 : VNet
resource "azurerm_virtual_network" "rafi-vnet" {
  name                = "rafi-network"
  resource_group_name = azurerm_resource_group.rafi-rg.name
  location            = azurerm_resource_group.rafi-rg.location
  address_space       = ["10.0.0.0/16"]
}

#Resource-3: Subnet 
resource "azurerm_subnet" "subnet" {
  name                 = "ansible-subnet"
  resource_group_name  = azurerm_resource_group.rafi-rg.name
  virtual_network_name = azurerm_virtual_network.rafi-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "public_ip" {
  name                = "ansible-pip"
  location            = azurerm_resource_group.rafi-rg.location
  resource_group_name = azurerm_resource_group.rafi-rg.name
  allocation_method   = "Dynamic"
}


#Resource- 4: NIC card for VM
resource "azurerm_network_interface" "ansible" {
  name                = "ansible-nic"
  location            = azurerm_resource_group.rafi-rg.location
  resource_group_name = azurerm_resource_group.rafi-rg.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  depends_on = [
    azurerm_virtual_network.rafi-vnet,
    azurerm_subnet.subnet
  ]
}

# Create Network Security Group and rules
resource "azurerm_network_security_group" "nsg" {
  name                = "ansible-nsg"
  location            = azurerm_resource_group.rafi-rg.location
  resource_group_name = azurerm_resource_group.rafi-rg.name


  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "web"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
