# Phase 2 copy

resource "azurerm_resource_group" "rg" {
  name     = "${local.prefix}-rg"
  location = var.location
  tags     = local.base_tags
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${local.prefix}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.base_tags
}

resource "azurerm_network_security_rule" "rule" {
  for_each                = var.nsg_rules
  name                    = each.key
  priority                = each.value.priority
  direction               = each.value.direction
  access                  = each.value.access
  protocol                = each.value.protocol
  source_port_range       = "*"
  destination_port_ranges = each.value.destination_ports
  source_address_prefixes = concat(
    each.value.source_cidrs,
    lower(try(each.value.allow_group, "")) == "http" ? var.allowed_cidrs_http :
    lower(try(each.value.allow_group, "")) == "https" ? var.allowed_cidrs_https :
    []
  )
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
