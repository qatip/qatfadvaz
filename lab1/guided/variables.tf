variable "subscription_id" { type = string }
variable "project_name"    { type = string }
variable "location"        { type = string }
variable "env"             { type = string }

variable "allowed_cidrs"   { type = list(string) }
#variable "allowed_cidrs"   { type = map(number) }
