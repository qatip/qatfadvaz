location     = "UK South"
env          = "dev"
project_name = "landing zone"

allow_groups = {
  http       = ["10.0.0.0/24", "10.0.1.0/24"]
  https      = ["10.0.2.0/24"]
  admin      = ["172.16.0.10/32"]
  breakglass = ["192.168.99.99/32"]
}

nsg_rules = {
  allow-web = {
    priority          = 100
    direction         = "Inbound"
    access            = "Allow"
    protocol          = "Tcp"
    destination_ports = ["443"]
    source_cidrs      = []
    allow_groups      = ["http", "https"]
  }

  allow-admin = {
    priority          = 110
    direction         = "Inbound"
    access            = "Allow"
    protocol          = "Tcp"
    destination_ports = ["22"]
    source_cidrs      = []
    allow_groups      = ["admin", "breakglass"]
  }

  allow-status = {
    priority          = 120
    direction         = "Inbound"
    access            = "Allow"
    protocol          = "Tcp"
    destination_ports = ["8080"]
    source_cidrs      = ["10.0.50.0/24"]
    allow_groups      = ["http"]
  }
}

vnet_address_space = "10.0.0.0/16"

subnet_cidrs = {
  data      = "10.0.2.0/24"
  app       = "10.0.1.0/24 "
  endpoints = "10.0.3.0/24"
}


