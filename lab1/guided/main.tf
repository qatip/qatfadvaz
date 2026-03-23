resource "azurerm_resource_group" "rg" {
  name     = "${var.project_name}-${var.env}-rg"
  location = var.location
  tags     = { project = var.project_name, env = var.env }
}

resource "azurerm_network_security_group" "app" {
  name                = "${var.project_name}-${var.env}-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = { project = var.project_name, env = var.env }
}

#######################################################################################
## Count variant start - comment/uncomment lines 17 and 33 to activate/de-activate
#######################################################################################
#/*
resource "azurerm_network_security_rule" "allow_https" {
  count                       = length(var.allowed_cidrs)
  name                        = "allow-https-${count.index}"  
  #name = "allow-https-${replace(replace(var.allowed_cidrs[count.index], "/", "-"), ".", "-")}"
  priority                    = 200 + count.index
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["443"]
  source_address_prefix       = var.allowed_cidrs[count.index]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.app.name
}
#*/
####################
## Count variant end
####################


############################################################################################
## For_each variant 1 start - comment/uncomment lines 42 and 62 to activate/de-activate
############################################################################################
/*
resource "azurerm_network_security_rule" "allow_https" {
  for_each = {
    for idx, cidr in var.allowed_cidrs :
    cidr => 200 + idx
  }
  
  name = "allow-https-${replace(replace(each.key, "/", "-"), ".", "-")}"  
 
  priority                    = each.value
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["443"]
  source_address_prefix       = each.key
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.app.name
}
*/
#########################
## For_each variant 1 end
#########################




############################################################################################
## For_each variant 2 start - comment/uncomment lines 73 and 88 to activate/de-activate
############################################################################################
/*
resource "azurerm_network_security_rule" "allow_https" {
  for_each = var.allowed_cidrs
  name                        = "allow-https-${replace(replace(each.key, "/", "-"), ".", "-")}"
  priority                    = each.value
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["443"]
  source_address_prefix       = each.key          
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.app.name
}
*/
#########################
## For_each variant 2 end
#########################