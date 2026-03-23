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


