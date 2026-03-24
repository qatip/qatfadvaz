vnet_address_space = "10.99.0.0/16" # not in approved_vnet_cidrs default list

subnet_cidrs = {
  app       = "10.99.1.0/24"
  data      = "10.99.2.0/24"
  endpoints = "10.99.3.0/24"
}

