# Phase 5 copy

variable "project_name" { type = string }
variable "env" { type = string }
variable "location" { type = string }

variable "allowed_cidrs_http" {
  type    = list(string)
  default = []
  validation {
    condition = alltrue([
      for c in var.allowed_cidrs_http :
      can(cidrnetmask(trimspace(c)))
    ])
    error_message = "All HTTP CIDRs must be valid CIDR blocks."
  }
}

variable "allowed_cidrs_https" {
  type    = list(string)
  default = []
  validation {
    condition = alltrue([
      for c in var.allowed_cidrs_https :
      can(cidrnetmask(trimspace(c)))
    ])
    error_message = "All HTTPS CIDRs must be valid CIDR blocks."
  }
}

variable "nsg_rules" {
  type = map(object({
    priority          = number
    direction         = string
    access            = string
    protocol          = string
    destination_ports = list(string)
    source_cidrs      = list(string)
    allow_group       = optional(string)
  }))

  validation {
    condition = alltrue([
      for name, rule in var.nsg_rules :
      alltrue([
        for c in rule.source_cidrs :
        can(cidrnetmask(trimspace(c)))
      ])
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
}
