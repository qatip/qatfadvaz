# Exemplar copy

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
  for_each = local.nsg_rules_normalised

  name                   = each.key
  priority               = each.value.priority
  direction              = title(each.value.direction)
  access                 = title(each.value.access)
  protocol               = title(each.value.protocol)
  source_port_range      = "*"
  destination_port_ranges = each.value.destination_ports

  source_address_prefixes = distinct(flatten(concat(
    each.value.source_cidrs,
    [
      for g in each.value.allow_groups :
      lookup(local.allow_groups_clean, g, [])
    ]
  )))

  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name

  lifecycle {
    precondition {
      condition = alltrue([
        for c in distinct(flatten(concat(
          each.value.source_cidrs,
          [
            for g in each.value.allow_groups :
            lookup(local.allow_groups_clean, g, [])
          ]
        ))) : c != "0.0.0.0/0"
      ])
      error_message = "Rule '${each.key}' contains source CIDR (0.0.0.0/0)."
    }

    precondition {
      condition     = length(each.value.destination_ports) > 0
      error_message = "Rule '${each.key}' has no destination ports after sanitisation."
    }

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

    /*
    # Priority uniqueness precondition check
    precondition {
      condition = alltrue([
        for d in distinct([
          for r in values(local.nsg_rules_normalised) : r.direction
        ]) :
        length([
          for r in values(local.nsg_rules_normalised) :
          r.priority
          if r.direction == d
        ]) == length(distinct([
          for r in values(local.nsg_rules_normalised) :
          r.priority
          if r.direction == d
        ]))
      ])
      error_message = "NSG rule priorities must be unique per direction (Inbound/Outbound)."
    }
    */
  }
}

