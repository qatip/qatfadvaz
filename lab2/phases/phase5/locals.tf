# Phase 5 copy

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

  nsg_rules_normalised = {
    for name, rule in local.nsg_rules_clean :
    name => {
      priority    = rule.priority
      direction   = lower(rule.direction)
      access      = lower(rule.access)
      protocol    = lower(rule.protocol)
      allow_group = lower(try(rule.allow_group, ""))

      source_cidrs = distinct([
        for c in rule.source_cidrs :
        lower(trimspace(c))
        if can(cidrnetmask(trimspace(c)))
      ])

      destination_ports = sort(distinct(compact([
        for p in try(rule.destination_ports, []) : (
          length(regexall("[^0-9 -]", trim(p, " -"))) == 0 ? (
            length(regexall("[0-9]+", trim(p, " -"))) == 1 ?
              regexall("[0-9]+", trim(p, " -"))[0] :
            length(regexall("[0-9]+", trim(p, " -"))) == 2 ?
              "${min(
                tonumber(regexall("[0-9]+", trim(p, " -"))[0]),
                tonumber(regexall("[0-9]+", trim(p, " -"))[1])
              )}-${max(
                tonumber(regexall("[0-9]+", trim(p, " -"))[0]),
                tonumber(regexall("[0-9]+", trim(p, " -"))[1])
              )}" :
            ""
          ) : ""
        )
      ])))

      destination_ports_dropped = [
        for p in try(rule.destination_ports, []) : p
        if (
          length(trim(p, " -")) > 0 &&
          (
            length(regexall("[^0-9 -]", trim(p, " -"))) > 0 ||
            length(regexall("[0-9]+", trim(p, " -"))) == 0 ||
            length(regexall("[0-9]+", trim(p, " -"))) > 2
          )
        )
      ]

      source_cidrs_dropped = [
        for c in try(rule.source_cidrs, []) : lower(trimspace(c))
        if (
          length(trimspace(c)) > 0 &&
          !can(cidrnetmask(trimspace(c)))
        )
      ]

    }
  }
}