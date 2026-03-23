# Phase 5 copy

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
  for_each                = local.nsg_rules_normalised
  name                    = each.key
  priority                = each.value.priority
  direction               = title(each.value.direction)
  access                  = title(each.value.access)
  protocol                = title(each.value.protocol)
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
  lifecycle {
    # 0.0.0.0/0 prohibited
    precondition {
      condition = alltrue([
        for c in concat(
          each.value.source_cidrs,
          each.value.allow_group == "http"
          ? local.allowed_cidrs_http_clean
          : each.value.allow_group == "https"
          ? local.allowed_cidrs_https_clean
          : []
        ) : c != "0.0.0.0/0"
      ])
      error_message = "Rule '${each.key}' contains source CIDR (0.0.0.0/0)."
    }
    # ports must exist after sanitisation
    precondition {
      condition     = length(each.value.destination_ports) > 0
      error_message = "Rule '${each.key}' has no destination ports after sanitisation."
    }

    # every numeric endpoint in each port spec must be 1–65535
    precondition {
      condition = alltrue([
        for p in each.value.destination_ports :
        alltrue([
          for n in regexall("[0-9]+", p) :
          tonumber(n) >= 1 && tonumber(n) <= 65535
        ])
      ])
      error_message = "Rule '${each.key}' contains destination ports outside the valid range (1–65535)."
    }
  }
}
