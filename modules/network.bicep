// Lab 01 - Network module (resource group scope)
//
// Creates two network security groups, then one virtual network
// with two subnets. Each subnet references its own NSG.
//
// Bicep and Terraform difference:
// In Terraform, the subnet-to-NSG link is a separate resource
// (azurerm_subnet_network_security_group_association).
// In Azure Resource Manager, the link is simply a property of the
// subnet (networkSecurityGroup.id), so no extra resource is needed.

metadata name = 'Lab 01 - Network module'
metadata author = 'Olivier Lumeau'

@description('Azure region for the network resources.')
param location string

@description('Name of the Azure virtual network.')
param virtualNetworkName string

@description('Address space assigned to the virtual network.')
param virtualNetworkAddressSpace array

@description('Name of the application subnet.')
param appSubnetName string

@description('Address prefix assigned to the application subnet.')
param appSubnetAddressPrefix string

@description('Name of the management subnet.')
param mgmtSubnetName string

@description('Address prefix assigned to the management subnet.')
param mgmtSubnetAddressPrefix string

@description('Name of the NSG associated with the application subnet.')
param appNsgName string

@description('Name of the NSG associated with the management subnet.')
param mgmtNsgName string

@description('Common Azure tags used to identify lab resources.')
param tags object

// ---------------------------------------------------------------
// 1. Network security group for the application subnet.
// Only the default Azure NSG rules are present in this lab.
// ---------------------------------------------------------------

resource appNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: appNsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// ---------------------------------------------------------------
// 2. Network security group for the management subnet.
// ---------------------------------------------------------------

resource mgmtNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: mgmtNsgName
  location: location
  tags: tags
  properties: {
    securityRules: []
  }
}

// ---------------------------------------------------------------
// 3. Virtual network with its two subnets.
// Subnets are declared inside the virtual network so that a
// redeployment never tries to remove and recreate them.
// defaultOutboundAccess is set to false (private subnets): Microsoft is
// retiring implicit outbound internet access for new virtual networks.
// The Terraform version of Lab 01 keeps the provider default (true).
// ---------------------------------------------------------------

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: virtualNetworkName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: virtualNetworkAddressSpace
    }
    subnets: [
      {
        name: appSubnetName
        properties: {
          addressPrefix: appSubnetAddressPrefix
          defaultOutboundAccess: false
          networkSecurityGroup: {
            id: appNsg.id
          }
        }
      }
      {
        name: mgmtSubnetName
        properties: {
          addressPrefix: mgmtSubnetAddressPrefix
          defaultOutboundAccess: false
          networkSecurityGroup: {
            id: mgmtNsg.id
          }
        }
      }
    ]
  }
}

// Security note: default NSG rules allow some traffic inside a virtual
// network. Two subnets alone are not equivalent to network isolation.

// ---------------------------------------------------------------
// Outputs
// ---------------------------------------------------------------

output virtualNetworkId string = vnet.id
output virtualNetworkAddressSpace array = vnet.properties.addressSpace.addressPrefixes
output appSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, appSubnetName)
output mgmtSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, mgmtSubnetName)
output appNsgId string = appNsg.id
output mgmtNsgId string = mgmtNsg.id
