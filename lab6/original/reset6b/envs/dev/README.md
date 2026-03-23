# Terraform Root Module – Exemplar README

## Purpose

This repository represents a **Terraform root module** used to deploy a complete,
environment-specific infrastructure stack by composing reusable, versioned modules.

The root module is responsible for **orchestration and wiring only**.
All infrastructure logic is delegated to child modules.

This pattern reflects recommended enterprise Terraform practices.

---

## What This Root Does

This root module is responsible for:

• Defining environment identity (dev / test / prod)  
• Isolating Terraform state per environment  
• Passing validated inputs into modules  
• Wiring module outputs into downstream dependencies  
• Selecting when new module versions are adopted  

This root **does not**:
• Create reusable logic  
• Contain complex resource definitions  
• Reference other roots or environments  

---

## Architecture Overview

This root composes the following logical layers:

1. **Security Layer**
   - Network Security Group (NSG)
   - Optional security rules

2. **Network Layer**
   - Virtual Network (VNet)
   - Optional subnets
   - Association to the security layer

Each layer is implemented as a **separately versioned Terraform module**
and consumed via a Git source reference.

---

## Module Consumption Pattern

This root follows a strict composition rule:

• Modules are **only** invoked from the root  
• Modules **never** reference other modules  
• All dependencies are resolved explicitly via outputs  

Example pattern:

Security module → outputs NSG ID  
Network module → consumes NSG ID  

This ensures:

• Clear dependency boundaries  
• Predictable change impact  
• Safe reuse across environments  

---

## Module Version Expectations

### Version Pinning Policy

All modules are consumed using **explicit version tags**.

Example:

```
source = "git::https://github.com/org/network-module.git?ref=v1.1.0"
```

This root **must not** use:

• Floating branches (e.g. main, develop)  
• Unpinned commits  
• Local paths in production scenarios  

### Why Version Pinning Matters

Pinning module versions ensures:

• Deterministic builds  
• Reproducible Terraform plans  
• Safe promotion from dev → test → prod  
• Clear auditability of changes  

A Terraform plan should change **only** when:

• Input values change, or  
• A module version reference is intentionally updated  

---

## Semantic Versioning Expectations

All modules follow semantic versioning:

| Change Type | Example | Version Impact |
|-----------|--------|----------------|
| Non-breaking | New output added | Patch / Minor |
| Backward compatible | New optional input | Minor |
| Breaking | Required input changed | Major |

This root may deliberately demonstrate **non-breaking upgrades**
where a module version changes without modifying infrastructure resources.

---

## Environment Responsibilities

Each environment root is responsible for:

• Its own backend state key  
• Environment-specific variable values  
• Deciding when to adopt newer module versions  

**Dev** is the first consumer of new module versions.  
**Test** and **Prod** adopt changes only after validation.

---

## State Management

Each environment uses a **separate Terraform state file**.

Only the backend configuration differs between environments.

This enforces:

• Blast-radius isolation  
• Independent promotion  
• Safe experimentation in dev  

---

## Usage (High Level)

Typical workflow:

1. Initialise Terraform  
2. Review module sources and versions  
3. Review environment-specific variables  
4. Run `terraform plan`  
5. Apply once validated  

Exact commands may vary by environment.

---

## Design Intent

This root is intentionally **thin**.

Its purpose is not to implement logic,
but to **compose contracts safely and predictably**.

All complexity belongs in:

• Modules  
• Inputs  
• Validations  

This separation is fundamental to scalable Terraform design.
