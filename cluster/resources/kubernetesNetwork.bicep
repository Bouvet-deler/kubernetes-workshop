param location string
param publicIPName string
param vNetName string
param subnetName string

param IPAllocationMethod string = 'Static'
param skuSize string = 'Standard'
param addressPrefixes array = ['10.0.0.0/16']
param subnetAddressPrefix string = '10.0.0.0/24'

resource pubicIP 'Microsoft.Network/publicIPAddresses@2023-09-01' = {
  name: publicIPName
  location: location
  properties: {
    publicIPAllocationMethod: IPAllocationMethod
  }
  sku: {
    name: skuSize
  }
}

resource vNet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }
    ]
  }
}
