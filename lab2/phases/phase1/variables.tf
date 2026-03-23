# Phase 1 original

variable "project_name" { type = string }
variable "env" { type = string }
variable "location" { type = string }

variable "allowed_cidrs_http" {
  type    = list(string)
  default = []
}

variable "allowed_cidrs_https" {
  type    = list(string)
  default = []
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
}
