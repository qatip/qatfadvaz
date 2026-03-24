This folder contains an exemplar implementation that performs full subnet containment and overlap validation using Terraform-only IP arithmetic.

This is not required knowledge for Lab 3 and is provided for illustration only.

NULL PROVIDER

The null provider used in this exists to support Terraform workflows where you need structure, ordering, or validation, but do not want to create or manage real infrastructure. Resources such as null_resource do not represent cloud services; instead, they act as logical placeholders that Terraform can reason about during planning and apply. This makes the null provider useful for orchestration, glue logic, and guardrails that sit around infrastructure rather than being infrastructure themselves.

In practice, the null provider is often used to enforce preconditions, coordinate dependencies, or perform checks that must pass before real resources are created. Because null_resource participates fully in Terraform’s dependency graph, it can block execution when conditions are not met, even though it produces no cloud-side artifacts. In the context of this lab’s exemplar, the null provider is used deliberately as a validation gate: if the CIDR calculations fail, Terraform stops during plan, before any Azure resources are touched.

It’s important to understand that the null provider is not a recommended default pattern for production infrastructure design. Its strength lies in flexibility, not clarity. Overuse can lead to Terraform configurations that are difficult to read, reason about, or maintain, because significant logic is hidden behind resources that do not correspond to real-world systems. This is why the null provider is typically reserved for exceptional cases—migration scaffolding, temporary checks, or demonstrations like the full network-validation exemplar shown here.

Seen in this light, the null provider reinforces a key lesson of the course: Terraform is capable of enforcing almost any rule if pushed hard enough, but capability does not equal best practice. Most real environments avoid complex validation logic by centralising responsibility—through IPAM systems, core network modules, or governance controls—rather than encoding exhaustive checks into every Terraform configuration.
