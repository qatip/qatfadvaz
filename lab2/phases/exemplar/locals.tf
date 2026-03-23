# Exemplar copy

locals {
  env_canon = join("-",regexall("[a-z0-9]+",lower(trimspace(var.env))))
  project_canon = join("-",regexall("[a-z0-9]+",lower(trimspace(var.project_name))))
  prefix        = "${local.project_canon}-${local.env_canon}"

  base_tags = {
    app = local.project_canon
    env = local.env_canon
  }

  # clean ALL allow groups:
  # - lower the group name
  # - trim + distinct the CIDRs
  allow_groups_clean = {
    for name, cidrs in var.allow_groups :
    lower(trimspace(name)) => distinct([
      for c in cidrs : trimspace(c)
    ])
  }

  # clean rule KEYS so for_each is stable
  nsg_rules_clean = {
    for k, v in var.nsg_rules :
    replace(
      replace(
        replace(lower(trimspace(k)), " ", "-"),
        "_", "-"
      ),
      ".", "-"
    ) => v
  }

  # normalise rule VALUES
  nsg_rules_normalised = {
    for name, rule in local.nsg_rules_clean :
    name => {
      priority         = rule.priority
      direction        = lower(rule.direction)
      access           = lower(rule.access)
      protocol         = lower(rule.protocol)

      # allow_groups is now a LIST on the rule
      allow_groups = [
        for g in try(rule.allow_groups, []) :
        lower(trimspace(g))
      ]

      # per-rule sources, cleaned and deduped
      source_cidrs = distinct([
        for c in rule.source_cidrs : trimspace(c)
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
    }
  }
}
