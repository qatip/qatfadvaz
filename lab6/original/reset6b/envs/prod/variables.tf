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
} 

variable "nsg_rules" { 
  description = "Map of NSG rules to create." 
  type = map(object({ 
    priority         = number 
    direction        = string 
    access           = string 
    protocol         = string 
    destination_ports = list(string) 
    source_cidrs     = list(string) 
    allow_groups     = optional(list(string), []) 
  })) 
} 
 
variable "vnet_address_space" { 
  type        = string 
  description = "CIDR for the Virtual Network address space." 
} 
 
variable "subnet_cidrs" { 
  type        = map(string) 
  description = "Map of logical subnet name to CIDR." 
}