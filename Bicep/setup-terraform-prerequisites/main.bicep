targetScope = 'subscription'

type githubOidcFederatedCredentialType = {
  organization: string
  repository: string
  entity: string
  target: string
}

// Parameters
@description('Name of the project to be used in naming resources')
param projectName string

@description('Location for all resources')
param location string = deployment().location

@description('Github OIDC federated credential configuration for the user assigned managed identity')
param githubOidcFederatedCredential githubOidcFederatedCredentialType

@description('Assign Storage Blob Data Contributor role to the user')
param assignRoleToUser bool = false

// Variables

// 4 last characters of a unique string based on subscription ID and project name to ensure uniqueness of resource names across deployments
var uniqueStringValue = substring(uniqueString(subscription().subscriptionId, projectName), 0, 4)

var tags = {
    project: projectName
    purpose: 'Terraform'
}

// Resources
resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-${projectName}'
  location: location
  tags: tags
}

module resourceGroupScoped './resourceGroupScoped/resource-group-scoped.bicep' = {
  name: 'deployResourceGroupScoped'
  scope: resourceGroup
  params: {
    projectName: projectName
    location: location
    uniqueSuffix: uniqueStringValue
    githubOidcFederatedCredential: githubOidcFederatedCredential
    assignRoleToUser: assignRoleToUser
    tags: tags
  }
}

// Outputs
output resourceGroupName string = resourceGroup.name
output uamiClientId string = resourceGroupScoped.outputs.uamiClientId
output uamiPrincipalId string = resourceGroupScoped.outputs.uamiPrincipalId
output storageAccountName string = resourceGroupScoped.outputs.storageAccountName
output storageContainerName string = resourceGroupScoped.outputs.storageContainerName
