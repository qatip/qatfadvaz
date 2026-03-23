###############################################################
# network_validation_exemplar.tf
#
# EXAMPLAR ONLY 
# -------------------------------------------------------------
# This file demonstrates how to perform FULL subnet validation
# (containment + overlap) using Terraform-only IPv4 arithmetic.
#
# It assumes:
# - var.vnet_address_space is a valid IPv4 CIDR (e.g. 10.0.0.0/16)
# - var.subnet_cidrs is a map(string) of valid IPv4 CIDRs
#
# If the CIDRs are invalid, Terraform may error while evaluating
# locals (by design for this scary exemplar).
###############################################################



locals {
  # -----------------------------
  # VNet range as integer bounds
  # -----------------------------
  vnet_cidr_trim  = trimspace(var.vnet_address_space)
  vnet_prefix_len = tonumber(element(split("/", local.vnet_cidr_trim), 1))

  vnet_net_ip     = cidrhost(local.vnet_cidr_trim, 0)
  vnet_net_octets = split(".", local.vnet_net_ip)

  vnet_net_int = (
    tonumber(local.vnet_net_octets[0]) * 16777216 +
    tonumber(local.vnet_net_octets[1]) * 65536 +
    tonumber(local.vnet_net_octets[2]) * 256 +
    tonumber(local.vnet_net_octets[3])
  )

  vnet_size     = pow(2, 32 - local.vnet_prefix_len)
  vnet_last_int = local.vnet_net_int + local.vnet_size - 1

  # ---------------------------------------------------------
  # Subnet ranges (each subnet becomes [net_int, last_int])
  # ---------------------------------------------------------
  subnet_list = [
    for name, cidr_raw in var.subnet_cidrs : {
      name       = lower(trimspace(name))
      cidr       = trimspace(cidr_raw)
      prefix_len = tonumber(element(split("/", trimspace(cidr_raw)), 1))

      net_ip     = cidrhost(trimspace(cidr_raw), 0)
      net_octets = split(".", cidrhost(trimspace(cidr_raw), 0))

      net_int = (
        tonumber(split(".", cidrhost(trimspace(cidr_raw), 0))[0]) * 16777216 +
        tonumber(split(".", cidrhost(trimspace(cidr_raw), 0))[1]) * 65536 +
        tonumber(split(".", cidrhost(trimspace(cidr_raw), 0))[2]) * 256 +
        tonumber(split(".", cidrhost(trimspace(cidr_raw), 0))[3])
      )

      size = pow(2, 32 - tonumber(element(split("/", trimspace(cidr_raw)), 1)))

      last_int = (
        (
          tonumber(split(".", cidrhost(trimspace(cidr_raw), 0))[0]) * 16777216 +
          tonumber(split(".", cidrhost(trimspace(cidr_raw), 0))[1]) * 65536 +
          tonumber(split(".", cidrhost(trimspace(cidr_raw), 0))[2]) * 256 +
          tonumber(split(".", cidrhost(trimspace(cidr_raw), 0))[3])
        )
        + pow(2, 32 - tonumber(element(split("/", trimspace(cidr_raw)), 1)))
        -1
      )
    }
  ]

  # ---------------------------------------------------------
  # Check 1: containment (every subnet inside the VNet bounds)
  # ---------------------------------------------------------
  subnets_contained_in_vnet = alltrue([
    for s in local.subnet_list :
    s.net_int >= local.vnet_net_int && s.last_int <= local.vnet_last_int
  ])

  # ---------------------------------------------------------
  # Check 2: overlap (no two subnets overlap)
  #
  # Two ranges overlap if:
  #   a.net_int <= b.last_int  AND  b.net_int <= a.last_int
  # ---------------------------------------------------------
  subnets_do_not_overlap = alltrue(flatten([
    for i in range(length(local.subnet_list)) : [
      for j in range(i + 1, length(local.subnet_list)) :
      !(
        local.subnet_list[i].net_int <= local.subnet_list[j].last_int &&
        local.subnet_list[j].net_int <= local.subnet_list[i].last_int
      )
    ]
  ]))

  # True if vnet_address_space is written on a network boundary (e.g. 10.1.0.0/16)
  vnet_is_network_boundary = (
    element(split("/", local.vnet_cidr_trim), 0) == local.vnet_net_ip
  )

  # True if every subnet CIDR is written on a network boundary (e.g. 10.1.1.0/24)
  subnets_are_network_boundaries = alltrue([
    for s in local.subnet_list :
    element(split("/", s.cidr), 0) == s.net_ip
  ])

  subnets_meet_minimum_size = alltrue([
    for s in local.subnet_list :
    s.prefix_len <= 29
  ])
}

# -------------------------------------------------------------
# Validation gate: fails during plan with clear messages
# -------------------------------------------------------------
resource "null_resource" "network_validation_gate" {
  triggers = {
    vnet    = trimspace(var.vnet_address_space)
    subnets = jsonencode(var.subnet_cidrs)
  }

  lifecycle {
    precondition {
      condition     = local.vnet_is_network_boundary
      error_message = "vnet_address_space must be written on a network boundary (e.g. 10.1.0.0/16), not ${var.vnet_address_space}."
    }

    precondition {
      condition     = local.subnets_are_network_boundaries
      error_message = "Each subnet CIDR must be written on a network boundary (e.g. 10.1.1.0/24). One or more entries use a host IP (e.g. 10.1.1.1/24)."
    }

    precondition {
      condition     = local.subnets_contained_in_vnet
      error_message = "One or more subnets are not fully contained within vnet_address_space (${var.vnet_address_space})."
    }

    precondition {
      condition     = local.subnets_do_not_overlap
      error_message = "One or more subnets overlap. Subnet CIDR ranges must not overlap."
    }

    precondition {
      condition     = local.subnets_meet_minimum_size
      error_message = "One or more subnets are smaller than /29. Azure subnets must be /29 or larger."
    }

  }
}
