data "azurerm_resource_group" "existing_rg" {
  name = var.resource_group
}

resource "azurerm_network_security_group" "nsg" {
    name = var.nsg_name
    resource_group_name = data.azurerm_resource_group.existing_rg.name
    location            = data.azurerm_resource_group.existing_rg.location
      
    tags =  {
    environment = var.nsg_tag
    }

    lifecycle {
      ignore_changes = [ name, tags ]
    }
}

resource "azurerm_network_security_rule" "rule1" {
    resource_group_name = data.azurerm_resource_group.existing_rg.name
    network_security_group_name = azurerm_network_security_group.nsg.name
    name                       = var.nsg_rule1_name
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"

    lifecycle {
      ignore_changes = [ name, protocol, direction, access ]
    }
}  


resource "azurerm_network_security_rule" "rule2" {
    resource_group_name = data.azurerm_resource_group.existing_rg.name
    network_security_group_name = azurerm_network_security_group.nsg.name
    name                       = var.nsg_rule2_name
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"

    lifecycle {
      ignore_changes = [ name, protocol, direction, access ]
    }
}
