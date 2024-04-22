@description('The base name of bicep resources.')
param baseName string = 'workshop'

@description('The name of the Managed Cluster resource.')
param clusterName string = '${baseName}-cluster'

@description('The location of the Managed Cluster resource.')
param location string = resourceGroup().location

@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = '${baseName}ACR${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the key vault.')
param keyVaultName string = 'KV-${uniqueString(resourceGroup().id)}'

param networkName string = 'network-${uniqueString(resourceGroup().id)}'

param publicIPName string = '${baseName}-publicIp'

param vNetName string = '${baseName}-vnet'

param subnetName string = '${baseName}-subnet'

module kubernetesCluster 'resources/kubernetesCluster.bicep' = {
  name: clusterName
  params: {
    location: location
    clusterName: clusterName
  }
}

module containerRegistry 'resources/azureContainerRegistry.bicep' = {
  name: acrName
  params: {
    baseName: baseName
    kubletObjectId: kubernetesCluster.outputs.kubletObjectId
    location: location
  }
}

module keyVault 'resources/keyVault.bicep' = {
  name: keyVaultName
  params: {
    location: location
    keyVaultName: keyVaultName
  }
}

module kubernetesNetwork 'resources/kubernetesNetwork.bicep' = {
  name: networkName
  params: {
    location: location
    publicIPName: publicIPName
    subnetName: subnetName 
    vNetName: vNetName
  }
}
