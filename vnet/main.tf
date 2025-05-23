# Using the Existing Resource Group
data "azurerm_resource_group" "existing_rg" {
  name = var.resource_group
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  address_space       = var.address_space

  lifecycle {
    ignore_changes = [ name, address_space ]
  }
}


# Dev Subnet
resource "azurerm_subnet" "subnet" {
  count = length(var.subnet_names)
  name                 = var.subnet_names[count.index]
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.address_prefixes[count.index]]

  lifecycle {
    ignore_changes = [ name, address_prefixes, virtual_network_name ]
    }
}

