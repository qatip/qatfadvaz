variable "location" { }

variable "name_prefix" {
  type    = string
  default = "adoagent"
}

variable "admin_source_cidr" {
  type        = string
  description = "CIDR allowed to RDP to the VM (e.g. your public IP /32)."
  default     = "0.0.0.0/0"
}

variable "vm_size" { }

variable "subscription_id" { }

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Local admin password for the Windows VM (min 12 chars, include upper/lower/number/symbol)."
}

variable "ado_install_script_version" {
  description = "Bump this to force the VM extension to re-download/run install-ado.ps1"
  type        = string
  default     = "v1"
}
