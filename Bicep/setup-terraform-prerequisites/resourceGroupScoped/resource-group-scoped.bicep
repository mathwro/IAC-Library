targetScope = 'resourceGroup'

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
param location string

@description('Unique suffix to ensure resource names are unique across deployments')
param uniqueSuffix string

@description('Github OIDC federated credential configuration for the user assigned managed identity')
param githubOidcFederatedCredential githubOidcFederatedCredentialType = {
  organization: ''
  repository: ''
  entity: ''
  target: ''
}

@description('Assign Storage Blob Data Contributor role to the user')
param assignRoleToUser bool = false

param tags object = {}

var hasGithubOidcFederatedCredential = !empty(trim(githubOidcFederatedCredential.organization)) && !empty(trim(githubOidcFederatedCredential.repository)) && !empty(trim(githubOidcFederatedCredential.entity)) && !empty(trim(githubOidcFederatedCredential.target))


resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'uami-${projectName}-${uniqueSuffix}'
  location: location
  tags: tags
}

resource uami_github_federated 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2024-11-30' = if (hasGithubOidcFederatedCredential) {
  name: 'federated-${projectName}-${uniqueSuffix}'
  parent: uami
  properties: {
    audiences: [
      'api://AzureADTokenExchange'
    ]
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:${githubOidcFederatedCredential.organization}/${githubOidcFederatedCredential.repository}:${githubOidcFederatedCredential.entity}:${githubOidcFederatedCredential.target}'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-06-01' = {
  name: 'str${projectName}${uniqueSuffix}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
  tags: tags
}

resource storageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-06-01' = {
  name: '${storageAccount.name}/default/tfstate'
  properties: {
    publicAccess: 'None'
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, uami.id, 'Storage Blob Data Contributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor role
    principalId: uami.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource roleAssignment_user 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (assignRoleToUser) {
  name: guid(storageAccount.id, deployer().objectId, 'Storage Blob Data Contributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor role
    principalId: deployer().objectId
    principalType: 'User'
  }
}

// Outputs
output uamiClientId string = uami.properties.clientId
output uamiPrincipalId string = uami.properties.principalId
output storageAccountName string = storageAccount.name
output storageContainerName string = storageContainer.name
