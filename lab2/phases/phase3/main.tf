# Phase 3 copy

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
  for_each                = local.nsg_rules_clean
  name                    = each.key
  priority                = each.value.priority
  direction               = each.value.direction
  access                  = each.value.access
  protocol                = each.value.protocol
  source_port_range       = "*"
  destination_port_ranges = each.value.destination_ports
  source_address_prefixes = concat(
    each.value.source_cidrs,
    lower(try(each.value.allow_group, "")) == "http" ? local.allowed_cidrs_http_clean :
    lower(try(each.value.allow_group, "")) == "https" ? local.allowed_cidrs_https_clean :
    []
  )
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
