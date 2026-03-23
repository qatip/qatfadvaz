resource "azurerm_resource_group" "rg" {
  name     = "${local.prefix}-rg"
  location = var.location
  tags     = local.base_tags
}

module "network" {
  source              = "git::https://github.com/testuser2697/terraform-azure-module-network.git?ref=v1.0.1"
  prefix              = local.prefix
  location            = var.location
  base_tags           = local.base_tags
  resource_group_name = azurerm_resource_group.rg.name
  nsg_id              = module.security.nsg_id
  vnet_address_space  = var.vnet_address_space
  subnet_cidrs        = var.subnet_cidrs
}
module "security" {
  source              = "git::https://github.com/testuser2697/terraform-azure-module-security.git?ref=v1.0.0"
  prefix              = local.prefix
  location            = var.location
  base_tags           = local.base_tags
  resource_group_name = azurerm_resource_group.rg.name
  allow_groups        = var.allow_groups
  nsg_rules           = var.nsg_rules

}

