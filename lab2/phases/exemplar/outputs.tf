output "destination_port_sanitisation_notes" {
  value = {
    for name, r in local.nsg_rules_normalised :
    name => r.destination_ports_dropped
    if length(r.destination_ports_dropped) > 0
  }
}