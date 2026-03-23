#/*
# Landing Zone lookup values (dev only)
variable "lz_resource_group_name" {
  description = "Resource Group name of the dev Landing Zone."
  type        = string
}

variable "lz_vnet_name" {
  description = "Virtual Network name in the dev Landing Zone."
  type        = string
}

variable "lz_subnet_name" {
  description = "Subnet name in the dev Landing Zone."
  type        = string
}

# Workload access
variable "admin_username" {
  description = "Admin username for the workload VM."
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key."
  type        = string
}
#*/
