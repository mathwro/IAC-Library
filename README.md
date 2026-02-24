# IAC-Library

Infrastructure-as-Code module library for reusable deployment building blocks.

This repository is designed to hold multiple module types (for example Bicep and Terraform), each focused on a specific infrastructure capability and documented for independent use.

## Repository goals

- Provide reusable, versionable IaC modules
- Keep modules small and purpose-driven
- Standardize documentation and usage patterns across module types
- Make it easy to discover and consume modules in other projects

## Repository structure

- [Bicep](Bicep)
	- Azure-native Bicep modules
- [Terraform](Terraform)
	- Terraform modules and supporting files

## Current modules

### Bicep

- [setup-terraform-prerequisites](Bicep/setup-terraform-prerequisites)
	- Bootstraps Azure prerequisites for Terraform remote state + GitHub OIDC
	- See: [module README](Bicep/setup-terraform-prerequisites/README.md)

### Terraform

- [website-project](Terraform/website-project)
	- Deploys a Static Web App + storage backend and configures custom domain DNS
	- See: [module README](Terraform/website-project/README.md)

## Using a module

1. Navigate to the module folder.
2. Read that module's README for required inputs and examples.
3. Deploy from the module's scope (for example, subscription scope for top-level Bicep entrypoints).

## Module standards

When adding a new module, include:

- A focused module purpose (single responsibility)
- A local README with purpose, inputs, outputs, and deployment example
- Sensible defaults and validations where possible
- Clear naming conventions for resources and parameters

## Contributing

- Keep changes scoped to the target module.
- Update the module README whenever inputs/outputs/behavior change.
- Add new modules to the "Current modules" section in this root README.
