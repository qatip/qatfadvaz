# Lab 3 challenge solution

variable "location" {
  type        = string
  description = "Azure region to deploy into."
}

variable "env" {
  type        = string
  description = "Environment name, e.g. dev/test/prod."
}

variable "project_name" {
  type        = string
  description = "Short project or application name."
}

variable "allow_groups" {
  description = "Named CIDR allow-lists that NSG rules can reference."
  type        = map(list(string))
  default     = {}

  validation {
    condition = alltrue([
      for name, cidrs in var.allow_groups :
      alltrue([for c in cidrs : can(cidrnetmask(trimspace(c)))])
    ])
    error_message = "All entries in allow_groups must be valid CIDR blocks."
  }
}

variable "nsg_rules" {
  description = "Map of NSG rules to create."
  type = map(object({
    priority          = number
    direction         = string
    access            = string
    protocol          = string
    destination_ports = list(string)
    source_cidrs      = list(string)
    allow_groups      = optional(list(string), [])
  }))

  validation {
    condition = alltrue([
      for name, rule in var.nsg_rules :
      alltrue([for c in rule.source_cidrs : can(cidrnetmask(trimspace(c)))])
    ])
    error_message = "One or more NSG rules contain an invalid CIDR in source_cidrs."
  }

  validation {
    condition = alltrue([
      for name, rule in var.nsg_rules :
      rule.priority >= 100 && rule.priority <= 4096
    ])
    error_message = "All NSG rules must have a priority between 100 and 4096."
  }

  validation {
    condition = alltrue([
      for _, rule in var.nsg_rules : alltrue([
        for g in rule.allow_groups :
        contains(
          [for k in keys(var.allow_groups) : lower(trimspace(k))],
          lower(trimspace(g))
        )
      ])
    ])
    error_message = "Each nsg_rules[*].allow_groups entry must match a key in var.allow_groups (comparison is trim+lowercase)."
  }
}

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

  validation {
    condition     = alltrue([for cidr in values(var.subnet_cidrs) : can(cidrnetmask(trimspace(cidr)))])
    error_message = "All subnet_cidrs values must be valid CIDR blocks."
  }

  validation {
    condition = alltrue([
      for cidr in values(var.subnet_cidrs) :
      tonumber(element(split("/", trimspace(cidr)), 1)) <= 29
    ])
    error_message = "Azure subnets must be /29 or larger (e.g. /29, /28, /27 ... /24)."
  }

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
