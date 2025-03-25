//********************************************
// Parameters
//********************************************

@description('Specifies a globally unique name the Azure Functions App.')
param name string

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the kind of the hosting plan.')
@allowed([
  'app'                                    // Windows Web app
  'app,linux'                              // Linux Web app
  'app,linux,container'                    // Linux Container Web app
  'hyperV'                                 // Windows Container Web App
  'app,container,windows'                  // Windows Container Web App
  'app,linux,kubernetes'                   // Linux Web App on ARC
  'app,linux,container,kubernetes'         // Linux Container Web App on ARC
  'functionapp'                            // Function Code App
  'functionapp,linux'                      // Linux Consumption Function app
  'functionapp,linux,container,kubernetes' // Function Container App on ARC
  'functionapp,linux,kubernetes'           // Function Code App on ARC
])
param kind string = 'functionapp,linux'

@description('Specifies the language runtime used by the Azure Functions App.')
@allowed([
  'dotnet'
  'dotnet-isolated'
  'python'
  'java'
  'node'
  'powerShell'
  'custom'
])
param runtimeName string

@description('Specifies the target language version used by the Azure Functions App.')
param runtimeVersion string

@description('Specifies the minimum TLS version for the Azure Functions App.')
@allowed([
  '1.0'
  '1.1'
  '1.2'
  '1.3'
])
param minTlsVersion string = '1.2'

@description('Specifies whether the public network access is enabled or disabled')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Specifies whether Always On is enabled for the Azure Functions App.')
param alwaysOn bool = true

@description('Specifies whether HTTPS is enforced for the Azure Functions App.')
param httpsOnly bool = true

@description('Specifies the maximum scale-out instance count limit for the app.')
@minValue(40)
@maxValue(1000)
param maximumInstanceCount int = 100

@description('Specifies the memory size of instances used by the app.')
@allowed([2048, 4096])
param instanceMemoryMB int = 2048

@description('Specifies the name of the Azure Functions App user-defined managed identity.')
param managedIdentityName string

@description('Specifies the name of the hosting plan.')
param hostingPlanName string

@description('Specifies allowed origins for client-side CORS requests on the site.')
param allowedCorsOrigins string[] = []

@description('Specifies whether all traffic is routed through the virtual network.')
param vnetRouteAllEnabled bool = true

@description('Specifies whether image pull is enabled through the virtual network.')
param vnetImagePullEnabled bool = true

@description('Specifies whether content share is enabled through the virtual network.')
param vnetContentShareEnabled bool = true

@description('Specifies whether backup and restore are enabled through the virtual network.')
param vnetBackupRestoreEnabled bool = true

@description('Specifies the name of the input container.')
@minLength(3)
param storageInputContainerName string = 'input'

@description('Specifies the name for the Azure Storage Account resource.')
param storageAccountName string

@description('Specifies the name of the Azure OpenAI resource.')
param openAiName string

@description('Specifies the name of the Azure OpenAI chat model deployment.')
param chatModelDeploymentName string

@description('Specifies the name of the Azure Cosmos DB account.')
param accountName string

@description('Specifies the name of the Azure Cosmos DB database.')
param databaseName string

@description('Specifies the name of the Azure Cosmos DB container.')
param containerName string

@description('Specifies the name of the Azure Application Insights.')
param applicationInsightsName string

@description('Specifies the name of the virtual network.')
param virtualNetworkName string

@description('Specifies the name of the subnet used by Azure Functions for the regional virtual network integration.')
param subnetName string

@description('Specifies the resource id of the Log Analytics workspace.')
param workspaceId string

@description('Specifies the resource tags.')
param tags object

@description('Specifies Azurre Functions extension verson.')
param extensionVersion string = '~4'

//********************************************
// Variables
//********************************************

// Generates a unique container name for deployments.
var deploymentStorageContainerName = 'packages'
var diagnosticSettingsName = 'diagnosticSettings'
var logCategories = [
  'FunctionAppLogs'
  'AppServiceAuthenticationLogs'
]
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

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: virtualNetworkName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  parent: virtualNetwork
  name: subnetName
}

resource hostingPlan 'Microsoft.Web/serverfarms@2024-04-01' existing = {
  name: hostingPlanName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource openAi 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  name: openAiName
}

resource account 'Microsoft.DocumentDB/databaseAccounts@2024-12-01-preview' existing = {
  name: toLower(accountName)
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityName
}

resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: name
  location: location
  kind: kind
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    serverFarmId: hostingPlan.id
    virtualNetworkSubnetId: subnet.id
    vnetRouteAllEnabled: vnetRouteAllEnabled
    vnetImagePullEnabled: vnetImagePullEnabled
    vnetContentShareEnabled: vnetContentShareEnabled
    vnetBackupRestoreEnabled: vnetBackupRestoreEnabled
    httpsOnly: httpsOnly
    siteConfig: {
      minTlsVersion: minTlsVersion
      alwaysOn: alwaysOn
      linuxFxVersion: toUpper('${runtimeName}|${runtimeVersion}')
      cors: {
        allowedOrigins: union(['https://portal.azure.com', 'https://ms.portal.azure.com'], allowedCorsOrigins)
      }
      publicNetworkAccess: publicNetworkAccess
    }
    functionAppConfig: hostingPlan.sku.tier == 'FlexConsumption' ? {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${storageAccount.properties.primaryEndpoints.blob}${deploymentStorageContainerName}'
          authentication: {
            type: 'managedIdentity'
            userAssignedIdentityResourceId: managedIdentity.id
          }
        }
      }
      scaleAndConcurrency: {
        maximumInstanceCount: maximumInstanceCount
        instanceMemoryMB: instanceMemoryMB
      }
      runtime: {
        name: runtimeName
        version: runtimeVersion
      }
    } : null
  }
  
  resource configAppSettings 'config' = {
    name: 'appsettings'
    properties: hostingPlan.sku.tier == 'FlexConsumption' ? {
      AzureWebJobsStorage__accountName: storageAccount.name
      STORAGE_ACCOUNT__blobServiceUri: storageAccount.properties.primaryEndpoints.blob
      STORAGE_ACCOUNT__queueServiceUri: storageAccount.properties.primaryEndpoints.queue
      STORAGE_ACCOUNT__tableServiceUri: storageAccount.properties.primaryEndpoints.table
      INPUT_STORAGE_CONTAINER_NAME: storageInputContainerName
      AZURE_OPENAI_ENDPOINT: openAi.properties.endpoint
      AZURE_CLIENT_ID: managedIdentity.properties.clientId
      CHAT_MODEL_DEPLOYMENT_NAME: chatModelDeploymentName
      COSMOS_DB_CONNECTION__accountEndpoint: account.properties.documentEndpoint
      COSMOS_DB_CONNECTION__credential: 'managedidentity'
      COSMOS_DB_CONNECTION__clientId: managedIdentity.properties.clientId
      COSMOS_DB_DATABASE: databaseName
      COSMOS_DB_CONTAINER: containerName
      APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString
      APPLICATIONINSIGHTS_AUTHENTICATION_STRING: 'ClientId=${managedIdentity.properties.clientId};Authorization=AAD'
      FUNCTIONS_EXTENSION_VERSION: extensionVersion
    } : {
      AzureWebJobsStorage__accountName: storageAccount.name
      STORAGE_ACCOUNT__blobServiceUri: storageAccount.properties.primaryEndpoints.blob
      STORAGE_ACCOUNT__queueServiceUri: storageAccount.properties.primaryEndpoints.queue
      STORAGE_ACCOUNT__tableServiceUri: storageAccount.properties.primaryEndpoints.table
      INPUT_STORAGE_CONTAINER_NAME: storageInputContainerName
      AZURE_OPENAI_ENDPOINT: openAi.properties.endpoint
      AZURE_CLIENT_ID: managedIdentity.properties.clientId
      CHAT_MODEL_DEPLOYMENT_NAME: chatModelDeploymentName
      COSMOS_DB_CONNECTION__accountEndpoint: account.properties.documentEndpoint
      COSMOS_DB_CONNECTION__credential: 'managedidentity'
      COSMOS_DB_CONNECTION__clientId: managedIdentity.properties.clientId
      COSMOS_DB_DATABASE: databaseName
      COSMOS_DB_CONTAINER: containerName
      APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.properties.ConnectionString
      APPLICATIONINSIGHTS_AUTHENTICATION_STRING: 'ClientId=${managedIdentity.properties.clientId};Authorization=AAD'
      FUNCTIONS_EXTENSION_VERSION: extensionVersion
      FUNCTIONS_WORKER_RUNTIME: runtimeName
      WEBSITE_MAX_DYNAMIC_APPLICATION_SCALE_OUT: string(maximumInstanceCount)
      WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
      WEBSITE_CONTENTSHARE: name
      WEBSITE_RUN_FROM_PACKAGE: '1'
      WEBSITE_USE_PLACEHOLDER_DOTNETISOLATED: '1'
    }
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(!empty(workspaceId)) {
  name: diagnosticSettingsName
  scope: functionApp
  properties: {
    workspaceId: workspaceId
    logs: logs
    metrics: metrics
  }
}

//********************************************
// Outputs
//********************************************

output id string = functionApp.id
output name string = functionApp.name
output defaultHostName string = functionApp.properties.defaultHostName
