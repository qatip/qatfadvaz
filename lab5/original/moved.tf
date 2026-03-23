#### Security module moves ####
/*
moved {
  from = azurerm_network_security_group.nsg
  to   = module.security.azurerm_network_security_group.nsg
}
moved {
  from = azurerm_network_security_rule.rule["allow-web"]
  to   = module.security.azurerm_network_security_rule.rule["allow-web"]
}
moved {
  from = azurerm_network_security_rule.rule["allow-status"]
  to   = module.security.azurerm_network_security_rule.rule["allow-status"]
}
moved {
  from = azurerm_network_security_rule.rule["allow-admin"]
  to   = module.security.azurerm_network_security_rule.rule["allow-admin"]
}
*/

### Network module moves ####
/*
moved {
  from = azurerm_subnet_network_security_group_association.subnet["app"]
  to   = module.networking.azurerm_subnet_network_security_group_association.subnet["app"]
}
moved {
  from = azurerm_subnet_network_security_group_association.subnet["data"]
  to   = module.networking.azurerm_subnet_network_security_group_association.subnet["data"]
}
moved {
  from = azurerm_subnet_network_security_group_association.subnet["endpoints"]
  to   = module.networking.azurerm_subnet_network_security_group_association.subnet["endpoints"]
}
moved {
  from = azurerm_virtual_network.vnet
  to   = module.networking.azurerm_virtual_network.vnet
}
moved {
  from = azurerm_subnet.subnet["app"]
  to   = module.networking.azurerm_subnet.subnet["app"]
}
moved {
  from = azurerm_subnet.subnet["data"]
  to   = module.networking.azurerm_subnet.subnet["data"]
}
moved {
  from = azurerm_subnet.subnet["endpoints"]
  to   = module.networking.azurerm_subnet.subnet["endpoints"]
}
*/
