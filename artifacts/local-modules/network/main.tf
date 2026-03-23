resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_address_space]
  tags                = local.mod_tags
}

resource "azurerm_subnet" "subnet" {
  for_each             = local.subnet_cidrs_clean
  name                 = "${var.prefix}-subnet-${each.key}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
}

resource "azurerm_subnet_network_security_group_association" "subnet" {
  for_each                  = azurerm_subnet.subnet
  subnet_id                 = each.value.id
  network_security_group_id = var.nsg_id 
}
