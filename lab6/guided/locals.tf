locals {

  env_canon     = join("-", regexall("[a-z0-9]+", lower(trimspace(var.env))))
  project_canon = join("-", regexall("[a-z0-9]+", lower(trimspace(var.project_name))))
  prefix        = "${local.project_canon}-${local.env_canon}"

  base_tags = {
    app = local.project_canon
    env = local.env_canon
  }

}