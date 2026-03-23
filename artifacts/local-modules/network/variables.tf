variable "location" {}
variable "prefix" {}
variable "resource_group_name" {}
variable "base_tags" {}
variable "nsg_id" {} 

variable "vnet_address_space" {
  type        = string
  description = "CIDR for the Virtual Network address space."

  validation {
    condition     = can(cidrnetmask(trimspace(var.vnet_address_space)))
    error_message = "vnet_address_space must be a valid CIDR block (e.g. 10.0.0.0/16)."
  }

  validation {
    condition     = contains(var.approved_vnet_cidrs, trimspace(var.vnet_address_space))
    error_message = "vnet_address_space must be one of the approved CIDRs for this lab (see approved_vnet_cidrs)."
  }
}

variable "subnet_cidrs" {
  type        = map(string)
  description = "Map of logical subnet name to CIDR."

  # Valid CIDR formatting
  validation {
    condition     = alltrue([for cidr in values(var.subnet_cidrs) : can(cidrnetmask(trimspace(cidr)))])
    error_message = "All subnet_cidrs values must be valid CIDR blocks."
  }

  # Azure subnet minimum size: /29 or larger (e.g. /29, /28, /27 ... /24).
  # Prefix length must be <= 29.
  validation {
    condition = alltrue([
      for cidr in values(var.subnet_cidrs) :
      tonumber(element(split("/", trimspace(cidr)), 1)) <= 29
    ])
    error_message = "Azure subnets must be /29 or larger (e.g. /29, /28, /27 ... /24)."
  }

  # Subnet must be smaller than the VNet (prefix length greater than VNet prefix length)
  validation {
    condition = alltrue([
      for cidr in values(var.subnet_cidrs) :
      tonumber(element(split("/", trimspace(cidr)), 1)) >
      tonumber(element(split("/", trimspace(var.vnet_address_space)), 1))
    ])
    error_message = "Each subnet CIDR must be smaller than the VNet (its prefix length must be greater than the VNet prefix length)."
  }
}

variable "approved_vnet_cidrs" {
  type        = set(string)
  description = "Approved VNet CIDRs for this Challenge."

  default = [
    "10.0.0.0/16",
    "10.1.0.0/16",
    "10.2.0.0/16",
    "10.3.0.0/16"
  ]
}
