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

module aks 'resources/kubernetesCluster.bicep' = {
  name: clusterName
  params: {
    location: location
    clusterName: clusterName
    osDiskSizeGB: osDiskSizeGB
    agentVMSize: agentVMSize
    agentCount: agentCount
    minCount: minCount
    maxCount: maxCount
  }
}

module acr 'resources/azureContainerRegistry.bicep' = {
  name: acrName
  params: {
    baseName: baseName
    kubletObjectId: aks.outputs.kubletObjectId
    location: location
  }
}

module keyVault 'resources/keyVault.bicep' = {
  name: keyVaultName
  params: {
    identityPrincipalId: acr.outputs.identityPrincipalId
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
