@description('The base name of bicep resources.')
param baseName string = 'workshop'

@description('The name of the Managed Cluster resource.')
param clusterName string = '${baseName}-cluster'

@description('The location of the Managed Cluster resource.')
param location string = resourceGroup().location

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 1

@description('The minimum of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param minCount int = 1

@description('The maximum of nodes for the cluster.')
@minValue(1)
@maxValue(200)
param maxCount int = 100

@description('The size of the Virtual Machine.')
param agentVMSize string = 'Standard_D2s_v3'

resource aks 'Microsoft.ContainerService/managedClusters@2024-01-01' = {
  name: clusterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${clusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        osDiskType: 'Managed'
        count: 2
        minCount: 2
        maxCount: 5
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
        enableNodePublicIP: false
        enableAutoScaling: true
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule'
        ]
      }
      {
        name: 'userpool'
        osDiskSizeGB: osDiskSizeGB
        osDiskType: 'Managed'
        count: agentCount
        minCount: minCount
        maxCount: maxCount
        vmSize: agentVMSize
        enableNodePublicIP: false
        osType: 'Linux'
        mode: 'User'
        enableAutoScaling: true
      }
    ]
    addonProfiles: {
      
    }
    oidcIssuerProfile: {
      enabled: true
    }
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'calico'
    }
  }
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
}

output controlPlaneFQDN string = aks.properties.fqdn

@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = '${baseName}ACR${uniqueString(resourceGroup().id)}'

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
  }
}

@description('Output the login server property for later use')
output loginServer string = acrResource.properties.loginServer

resource acrPullRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
}

resource assignAcrPullToAks 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id)
  scope: acrResource
  properties: {
    principalId: aks.properties.identityProfile.kubeletidentity.objectId
    roleDefinitionId: acrPullRoleDefinition.id
  }
}

@description('Name of the identity k8s will use with the vault')
param identityName string = 'k8s-identity'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

@description('Specifies the name of the key vault.')
param keyVaultName string = 'KV-${uniqueString(resourceGroup().id)}'

@description('Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.')
param enabledForDeployment bool = false

@description('Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.')
param enabledForDiskEncryption bool = false

@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param enabledForTemplateDeployment bool = false

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string = subscription().tenantId

@description('Specifies the permissions to keys in the vault. Valid values are: all, encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, and purge.')
param keysPermissions array = [
  'get'
  'list'
]

@description('Specifies the permissions to secrets in the vault. Valid values are: all, get, list, set, delete, backup, restore, recover, and purge.')
param secretsPermissions array = [
  'get'
  'list'
]

@description('Specifies whether the key vault is a standard vault or a premium vault.')
@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    tenantId: tenantId
    accessPolicies: [
      {
        objectId: managedIdentity.properties.principalId
        tenantId: tenantId
        permissions: {
          keys: keysPermissions
          secrets: secretsPermissions
        }
      }
      {
        objectId: '44988c10-927b-4b76-b347-0349acdeac10'
        tenantId: tenantId
        permissions: {
          keys: keysPermissions
          secrets: secretsPermissions
        }
      }
      {
        objectId: 'd0fbce97-c7b5-4e34-9656-fdf27eaf8ec9'
        tenantId: tenantId
        permissions: {
          keys: keysPermissions
          secrets: secretsPermissions
        }
      }
    ]
    sku: {
      name: skuName
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}


param publicIPName string = '${baseName}-publicIp'

resource pubicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}


param vNetName string = '${baseName}-vnet'

param subnetName string = '${baseName}-subnet'

resource vNet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource pgUsername 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: kv
  name: 'PostgresUsername'
  properties: {
    value: 'postgres'
  }
}

resource pgPassword 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: kv
  name: 'PostgresPassword'
  properties: {
    value: uniqueString(resourceGroup().id)
  }
}
