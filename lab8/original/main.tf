/*
resource "azurerm_network_interface" "legacy" {
  accelerated_networking_enabled = false
  auxiliary_mode                 = null
  auxiliary_sku                  = null
  dns_servers                    = []
  edge_zone                      = null
  internal_dns_name_label        = null
  ip_forwarding_enabled          = false
  location                       = "uksouth"
  name                           = "legacy-nic"
  resource_group_name            = "legacy-rg"
  tags                           = {}
  ip_configuration {
    gateway_load_balancer_frontend_ip_configuration_id = null
    name                                               = "ipconfig1"
    primary                                            = true
    private_ip_address                                 = "10.90.1.4"
    private_ip_address_allocation                      = "Dynamic"
    private_ip_address_version                         = "IPv4"
    public_ip_address_id                               = null
    subnet_id                                          = azurerm_subnet.legacy.id
  }
}

resource "azurerm_virtual_network" "legacy" {
  address_space = ["10.90.0.0/16"]
  bgp_community = null
  dns_servers   = []
  edge_zone     = null
  # flow_timeout_in_minutes        = 0
  location                       = "uksouth"
  name                           = "legacy-vnet"
  private_endpoint_vnet_policies = "Disabled"
  resource_group_name            = "legacy-rg"
  tags                           = {}
}

resource "azurerm_subnet" "legacy" {
  address_prefixes                              = ["10.90.1.0/24"]
  default_outbound_access_enabled               = true
  name                                          = "legacy-subnet"
  private_endpoint_network_policies             = "Disabled"
  private_link_service_network_policies_enabled = true
  resource_group_name                           = "legacy-rg"
  service_endpoint_policy_ids                   = []
  service_endpoints                             = []
  sharing_scope                                 = null
  virtual_network_name                          = "legacy-vnet"
}
*/

data "azurerm_resource_group" "lz" { 
name = var.lz_resource_group_name 
} 
 
data "azurerm_virtual_network" "lz" { 
name = var.lz_vnet_name 
resource_group_name = data.azurerm_resource_group.lz.name 
} 
 
data "azurerm_subnet" "lz" { 
name = var.lz_subnet_name 
virtual_network_name = data.azurerm_virtual_network.lz.name 
resource_group_name  = data.azurerm_resource_group.lz.name 
}

resource "azurerm_network_interface" "bu_nic" { 
  name                = "nic-bu-workload" 
  location            = data.azurerm_resource_group.lz.location 
  resource_group_name = data.azurerm_resource_group.lz.name 
 
  ip_configuration { 
    name                          = "ipconfig1" 
    subnet_id                     = data.azurerm_subnet.lz.id 
    private_ip_address_allocation = "Dynamic" 
  } 
}

resource "azurerm_linux_virtual_machine" "bu_vm" { 
  name = "vm-bu-workload" 
  location = data.azurerm_resource_group.lz.location 
  resource_group_name = data.azurerm_resource_group.lz.name 
  size = "Standard_B1s" 
 
  admin_username = var.admin_username 
 
  network_interface_ids = [ 
    azurerm_network_interface.bu_nic.id
  ] 
 
  admin_ssh_key { 
    username   = var.admin_username 
    public_key = file(var.ssh_public_key_path) 
  } 
 
  os_disk { 
    caching = "ReadWrite" 
    storage_account_type = "Standard_LRS" 
  } 
 
  source_image_reference { 
    publisher = "Canonical" 
    offer = "0001-com-ubuntu-server-jammy" 
    sku = "22_04-lts" 
    version = "latest" 
  } 
}

# Replacement NIC that consumes the Landing Zone subnet 
resource "azurerm_network_interface" "legacy_replacement" { 
  name = "legacy-nic-replacement" 
  location = data.azurerm_resource_group.lz.location 
  resource_group_name = data.azurerm_resource_group.lz.name 
 
  ip_configuration { 
    name = "ipconfig1" 
    subnet_id = data.azurerm_subnet.lz.id 
    private_ip_address_allocation = "Dynamic" 
  } 
}
