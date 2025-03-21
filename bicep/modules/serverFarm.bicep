//********************************************
// Parameters
//********************************************

@description('Specifies the name of the hosting plan.')
param name string

@description('Specifies the location of the hosting plan.')
param location string

@description('Specifies the tier name for the hosting plan.')
@allowed([
  'Basic'
  'Standard'
  'ElasticPremium'
  'Premium'
  'PremiumV2'
  'Premium0V3'
  'PremiumV3'
  'PremiumMV3'
  'Isolated'
  'IsolatedV2'
  'WorkflowStandard'
  'FlexConsumption'
])
param skuTier string = 'ElasticPremium'

@description('Specifies the SKU name for the hosting plan.')
@allowed([
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'EP1'
  'EP2'
  'EP3'
  'P1'
  'P2'
  'P3'
  'P1V2'
  'P2V2'
  'P3V2'
  'P0V3'
  'P1V3'
  'P2V3'
  'P3V3'
  'P1MV3'
  'P2MV3'
  'P3MV3'
  'P4MV3'
  'P5MV3'
  'I1'
  'I2'
  'I3'
  'I1V2'
  'I2V2'
  'I3V2'
  'I4V2'
  'I5V2'
  'I6V2'
  'WS1'
  'WS2'
  'WS3'
  'FC1'
])
param skuName string = 'EP1'

@description('Specifies the kind of the hosting plan.')
@allowed([
  'app'
  'elastic'
  'functionapp'
  'windows'
  'linux'
])
param kind string = 'elastic'

@description('Specifies whether the hosting plan is zone redundant.')
param zoneRedundant bool = true

@description('Specifies the resource id of the Log Analytics workspace.')
param workspaceId string

@description('Specifies whether the hosting plan is reserved.')
param isReserved bool

@description('Specifies the resource tags.')
param tags object

//********************************************
// Variables
//********************************************

var diagnosticSettingsName = 'diagnosticSettings'
var logCategories = []
var metricCategories = [
  'AllMetrics'
]
var logs = [
  for category in logCategories: {
    category: category
    enabled: true
    retentionPolicy: {
      enabled: true
      days: 0
    }
  }
]
var metrics = [
  for category in metricCategories: {
    category: category
    enabled: true
    retentionPolicy: {
      enabled: true
      days: 0
    }
  }
]

//********************************************
// Resources
//********************************************

resource hostingPlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  sku: {
    tier: skuTier
    name: skuName
  }
  properties: {
    reserved: isReserved
    zoneRedundant: zoneRedundant
    maximumElasticWorkerCount: skuTier == 'FlexConsumption' ? 1 : 20
  }
}

resource blobServiceDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(!empty(workspaceId)) {
  name: diagnosticSettingsName
  scope: hostingPlan
  properties: {
    workspaceId: workspaceId
    logs: logs
    metrics: metrics
  }
}

//********************************************
// Outputs
//********************************************

output id string = hostingPlan.id
output name string = hostingPlan.name
