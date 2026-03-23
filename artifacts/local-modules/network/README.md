# Network Module

## Purpose
This module provisions a virtual network and optional subnets within a supplied resource group.
It is designed to be consumed by application root modules and does not create resource groups itself.

## Module Contract

### Required Inputs (Root-to-Module Contract)
These values **must** be supplied by the root module.

| Variable                   | Type        | Description                                      |
|----------------------------|-------------|--------------------------------------------------|
| prefix                     | string      | Naming prefix applied to all resources           |
| location                   | string      | Azure region for all resources                   |
| base_tags                  | map(string) | Standardised tags applied to all resources       |
| resource_group_name        | string      | Target resource group name                       |
| nsg_id                     | string      | ID of an existing Network Security Group         |

### Optional Inputs (Configuration)
These values may be supplied by the root module or defaulted.

| Variable               | Type        | Default         | Description                                      |
|------------------------|-------------|-----------------|--------------------------------------------------|
| vnet_address_space     | list(string)| ["10.0.0.0/16"] | Address space for the virtual network            |
| subnet_cidrs           | map(string) | {}              | Map of subnet names to CIDR blocks               |

> ⚠️ **Important:** An empty `subnet_cidrs` map will result in a VNet with no subnets.
This is intentional for teaching purposes but may be unsafe in production without validation.

## Outputs

| Output Name | Description                         |
|------------|-------------------------------------|
| vnet_id    | The ID of the virtual network        |
| vnet_name  | The name of the virtual network      |

## Dependencies
This module expects an existing Network Security Group to be created externally
and passed in via `nsg_id`. The module does not create or manage NSGs.

## Versioning
This module follows semantic versioning:
- Patch versions add non-breaking outputs or defaults
- Minor versions extend functionality
- Major versions may introduce breaking contract changes
