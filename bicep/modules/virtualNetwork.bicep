//********************************************
// Parameters
//********************************************

@description('Specifies the name of the virtual network.')
param name string

@description('Specifies the delegation service name.')
param delegationServiceName string

@description('Specifies the address prefixes of the virtual network.')
param virtualNetworkAddressPrefixes string = '10.0.0.0/8'

@description('Specifies the name of the subnet used by Azure Functions for the regional virtual network integration.')
param functionAppSubnetName string = 'functionAppSubnet'

@description('Specifies the address prefix of the subnet used by Azure Functions for the regional virtual network integration.')
param functionAppSubnetAddressPrefix string = '10.0.0.0/24'

@description('Specifies the name of the subnet which contains private endpoints.')
param peSubnetName string = 'PeSubnet'

@description('Specifies the address prefix of the subnet which contains private endpoints.')
param peSubnetAddressPrefix string = '10.0.1.0/24'

@description('Specifies the name of the Azure NAT Gateway.')
param natGatewayName string

@description('Specifies a list of availability zones denoting the zone in which Nat Gateway should be deployed.')
param natGatewayZones array = []

@description('Specifies the number of Public IPs to create for the Azure NAT Gateway.')
param natGatewayPublicIps int = 1

@description('Specifies the idle timeout in minutes for the Azure NAT Gateway.')
param natGatewayIdleTimeoutMins int = 30

@description('Specifies the resource id of the Log Analytics workspace.')
param workspaceId string

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the resource tags.')
param tags object

//********************************************
// Variables
//********************************************

var diagnosticSettingsName = 'diagnosticSettings'
var vnetLogCategories = [
  'VMProtectionAlerts'
]
var vnetMetricCategories = [
  'AllMetrics'
]
var vnetLogs = [for category in vnetLogCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: 0
  }
}]
var vnetMetrics = [for category in vnetMetricCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: 0
  }
}]
var publicIpLogCategories = [
  'DDoSProtectionNotifications'
  'DDoSMitigationFlowLogs'
  'DDoSMitigationReports'
]
var publicIpMetricCategories = [
  'AllMetrics'
]
var publicIpLogs = [for category in publicIpLogCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: 0
  }
}]
var publicIpMetrics = [for category in publicIpMetricCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: 0
  }
}]

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefixes
      ]
    }
    subnets: [
      {
        name: functionAppSubnetName
        properties: {
          addressPrefix: functionAppSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
          natGateway: {
            id: natGateway.id
          }
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: delegationServiceName
              }
            }
          ]
        }
      }
      {
        name: peSubnetName
        properties: {
          addressPrefix: peSubnetAddressPrefix
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

// NAT Gateway
resource natGatewayPublicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' =  [for i in range(0, natGatewayPublicIps): {
  name: natGatewayPublicIps == 1 ? '${natGatewayName}-public-ip' : '${natGatewayName}-public-ip-${i + 1}'
  location: location
  sku: {
    name: 'Standard'
  }
  zones: !empty(natGatewayZones) ? natGatewayZones : []
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}]

resource natGateway 'Microsoft.Network/natGateways@2024-05-01' = {
  name: natGatewayName
  location: location
  sku: {
    name: 'Standard'
  }
  zones: !empty(natGatewayZones) ? natGatewayZones : []
  properties: {
    publicIpAddresses: [for i in range(0, natGatewayPublicIps): {
      id: natGatewayPublicIp[i].id
    }]
    idleTimeoutInMinutes: natGatewayIdleTimeoutMins
  }
  dependsOn: [
    natGatewayPublicIp
  ]
}

// Diagnostic Settings
resource vnetDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: vnet
  properties: {
    workspaceId: workspaceId
    logs: vnetLogs
    metrics: vnetMetrics
  }
}

resource publicIpDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [for i in range(0, natGatewayPublicIps): {
  name: diagnosticSettingsName
  scope: natGatewayPublicIp[i]
  properties: {
    workspaceId: workspaceId
    logs: publicIpLogs
    metrics: publicIpMetrics
  }
}]

//********************************************
// Outputs
//********************************************

output virtualNetworkId string = vnet.id
output name string = vnet.name
output functionAppSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, functionAppSubnetName)
output peSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, peSubnetName)
output functionAppSubnetName string = functionAppSubnetName
