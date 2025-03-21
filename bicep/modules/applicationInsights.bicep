//********************************************
// Parameters
//********************************************

@description('Specifies the name of the Azure Application Insights.')
param name string

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the type of application being monitored..')
@allowed([
  'web'
  'other'
])
param applicationType string = 'web'

@description('Specifies whether IP masking is enabled.')
param disableIpMasking bool = false

@description('Specifies whether the application is enabled for local authentication.')
param disableLocalAuth bool = false

@description('Specifies whether forcing users to create their own storage account for profiler and debugger.')
param forceCustomerStorageForProfiler bool = false

@description('Specifies whether purging data immediately after 30 days.')
param immediatePurgeDataOn30Days bool = true

@description('Specifies the network access type for accessing Application Insights ingestion.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Specifies the network access type for accessing Application Insights query.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

@description('Specifies the Azure Log Analytics workspace ID.')
param workspaceId string

@description('Specifies the resource tags.')
param tags object

//********************************************
// Resources
//********************************************

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: applicationType
    DisableIpMasking: disableIpMasking
    DisableLocalAuth: disableLocalAuth
    Flow_Type: 'Bluefield'
    ForceCustomerStorageForProfiler: forceCustomerStorageForProfiler
    ImmediatePurgeDataOn30Days: immediatePurgeDataOn30Days
    IngestionMode: 'LogAnalytics'
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    Request_Source: 'rest'
    WorkspaceResourceId: workspaceId
  }
}

//********************************************
// Outputs
//********************************************

output id string = applicationInsights.id
output name string = applicationInsights.name
