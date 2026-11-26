// Lab 01 - Parameter file (equivalent to a terraform.tfvars file)
//
// Values below repeat the defaults from main.bicep so that they are
// easy to read and change in one place. No secrets belong here.

using 'main.bicep'

param location = 'westeurope'
param resourceGroupName = 'rg-lab01-network-dev-weu-002'
param virtualNetworkName = 'vnet-lab01-network-dev-weu-002'
param virtualNetworkAddressSpace = [
  '10.10.0.0/16'
]
param appSubnetName = 'snet-app-dev-weu-002'
param appSubnetAddressPrefix = '10.10.1.0/24'
param mgmtSubnetName = 'snet-mgmt-dev-weu-002'
param mgmtSubnetAddressPrefix = '10.10.2.0/24'
param appNsgName = 'nsg-app-dev-weu-002'
param mgmtNsgName = 'nsg-mgmt-dev-weu-002'
param tags = {
  environment: 'dev'
  project: 'lab01-azure-networking'
  managed_by: 'bicep'
}
