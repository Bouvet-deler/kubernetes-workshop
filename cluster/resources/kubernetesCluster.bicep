param location string
param clusterName string

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 2

@description('The minimum of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param minCount int = 1

@description('The maximum of nodes for the cluster.')
@minValue(1)
@maxValue(200)
param maxCount int = 100

@description('The size of the Virtual Machine.')
param agentVMSize string = 'Standard_D8ds_v5'

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

output kubletObjectId string = aks.properties.identityProfile.kubeletidentity.objectId
