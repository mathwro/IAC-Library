# Terraform Prerequisites (Bicep)

This module provisions the Azure prerequisites needed to run Terraform with remote state and GitHub OIDC authentication.

## Purpose

Use this module to bootstrap:

- A dedicated resource group for Terraform prerequisites
- A user-assigned managed identity (UAMI)
- An optional GitHub OIDC federated credential on that UAMI
- A storage account and private blob container (`tfstate`) for Terraform state
- Role assignments so Terraform can access the state container

## Module structure

- `main.bicep` (subscription scope)
	- Creates the resource group
	- Invokes the resource-group-scoped module
- `resourceGroupScoped/resource-group-scoped.bicep` (resource group scope)
	- Creates identity, storage, container, and role assignments

## Inputs (`main.bicep`)

- `projectName` (string, required): Logical project name used in resource naming
- `location` (string, required): Azure region for resources
- `githubOidcFederatedCredential` (object, optional):
	- `organization`
	- `repository`
	- `entity` (for example `ref` or `environment`)
	- `target` (for example `refs/heads/main`)
- `assignRoleToUser` (bool, optional, default `false`): Assigns `Storage Blob Data Contributor` to the deploying user

If all `githubOidcFederatedCredential` fields are empty, the federated credential resource is skipped.

## Outputs (`main.bicep`)

- `resourceGroupName`
- `uamiClientId`
- `uamiPrincipalId`
- `storageAccountName`
- `storageContainerName`

## Example deployment

```bash
az deployment sub create \
	--name tf-prereqs \
	--location westeurope \
	--template-file ./main.bicep \
	--parameters projectName=myproject location=westeurope assignRoleToUser=true \
	--parameters githubOidcFederatedCredential='{"organization":"my-org","repository":"my-repo","entity":"ref","target":"refs/heads/main"}'
```

## Required permissions

The deploying principal typically needs permission to:

- Create resource groups at subscription scope
- Create managed identities and federated credentials
- Create storage accounts and containers
- Create role assignments (`Microsoft.Authorization/roleAssignments/write`)
