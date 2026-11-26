// Lab 01 - Azure Networking Fundamentals (Bicep version)
//
// Same architecture as the Terraform version of Lab 01:
// one resource group, one virtual network, two subnets,
// and one network security group per subnet.
//
// Deployed at subscription scope because the template creates
// the resource group itself. The network resources are deployed
// inside that resource group by the module modules/network.bicep.
//
// No virtual machines, public IP addresses, or custom security rules
// are created by this lab.

metadata name = 'Lab 01 - Azure Networking Fundamentals'
metadata description = 'One resource group, one virtual network, two subnets and two NSGs.'
metadata author = 'Olivier Lumeau'

targetScope = 'subscription'

// ---------------------------------------------------------------
// Parameters (equivalent to variables.tf)
// Default values follow the Terraform version of Lab 01, with the
// instance number 002 so that both versions can run side by side.
// ---------------------------------------------------------------

@description('Azure region in which the lab resources will be created.')
param location string = 'westeurope'

@description('Name of the resource group containing the lab resources.')
param resourceGroupName string = 'rg-lab01-network-dev-weu-002'

@description('Name of the Azure virtual network.')
param virtualNetworkName string = 'vnet-lab01-network-dev-weu-002'

@description('Address space assigned to the virtual network.')
param virtualNetworkAddressSpace array = [
  '10.10.0.0/16'
]

@description('Name of the application subnet.')
param appSubnetName string = 'snet-app-dev-weu-002'

@description('Address prefix assigned to the application subnet.')
param appSubnetAddressPrefix string = '10.10.1.0/24'

@description('Name of the management subnet.')
param mgmtSubnetName string = 'snet-mgmt-dev-weu-002'

@description('Address prefix assigned to the management subnet.')
param mgmtSubnetAddressPrefix string = '10.10.2.0/24'

@description('Name of the network security group associated with the application subnet.')
param appNsgName string = 'nsg-app-dev-weu-002'

@description('Name of the network security group associated with the management subnet.')
param mgmtNsgName string = 'nsg-mgmt-dev-weu-002'

@description('Common Azure tags used to identify lab resources.')
param tags object = {
  environment: 'dev'
  project: 'lab01-azure-networking'
  managed_by: 'bicep'
}

// ---------------------------------------------------------------
// 1. Resource group: the logical container for the lab.
// ---------------------------------------------------------------

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// ---------------------------------------------------------------
// 2. Network resources, deployed inside the resource group.
// ---------------------------------------------------------------

module network 'modules/network.bicep' = {
  name: 'lab01-network'
  scope: rg
  params: {
    location: location
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressSpace: virtualNetworkAddressSpace
    appSubnetName: appSubnetName
    appSubnetAddressPrefix: appSubnetAddressPrefix
    mgmtSubnetName: mgmtSubnetName
    mgmtSubnetAddressPrefix: mgmtSubnetAddressPrefix
    appNsgName: appNsgName
    mgmtNsgName: mgmtNsgName
    tags: tags
  }
}

// ---------------------------------------------------------------
// Outputs (equivalent to outputs.tf). No credentials are exposed.
// ---------------------------------------------------------------

@description('Name of the resource group hosting the lab.')
output resourceGroupName string = rg.name

@description('Azure resource ID of the lab resource group.')
output resourceGroupId string = rg.id

@description('Azure resource ID of the virtual network.')
output virtualNetworkId string = network.outputs.virtualNetworkId

@description('Address spaces assigned to the virtual network.')
output virtualNetworkAddressSpace array = network.outputs.virtualNetworkAddressSpace

@description('Azure resource ID of the application subnet.')
output appSubnetId string = network.outputs.appSubnetId

@description('Azure resource ID of the management subnet.')
output mgmtSubnetId string = network.outputs.mgmtSubnetId

@description('Azure resource ID of the application network security group.')
output appNsgId string = network.outputs.appNsgId

@description('Azure resource ID of the management network security group.')
output mgmtNsgId string = network.outputs.mgmtNsgId
