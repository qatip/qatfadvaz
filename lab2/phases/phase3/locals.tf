# Phase 3 copy

locals {
  env_canon = join("-",regexall("[a-z0-9]+",lower(trimspace(var.env))))
  project_canon = join("-",regexall("[a-z0-9]+",lower(trimspace(var.project_name))))
  prefix        = "${local.project_canon}-${local.env_canon}"

  base_tags = {
    app = local.project_canon
    env = local.env_canon
  }

  allowed_cidrs_http_clean = distinct([
    for c in var.allowed_cidrs_http :
    lower(trimspace(c))
  ])

  allowed_cidrs_https_clean = distinct([
    for c in var.allowed_cidrs_https :
    lower(trimspace(c))
  ])

  nsg_rules_clean = {
    for k, v in var.nsg_rules :
    replace(replace(replace(lower(trimspace(k)), " ", "-"), "_", "-"), ".", "-")
    => v
  }
}