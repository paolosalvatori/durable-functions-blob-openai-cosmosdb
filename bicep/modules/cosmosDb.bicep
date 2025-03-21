//********************************************
// Parameters
//********************************************

@description('Specifies the name of the Azure Cosmos DB account.')
param accountName string

@description('Indicates the type of database account. This can only be set at database account creation.')
@allowed([
  'GlobalDocumentDB'
  'MongoDB'
  'Parse'
])
param kind string = 'GlobalDocumentDB'

@description('Specifies whether the public network access is enabled or disabled')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Indicates what services are allowed to bypass firewall checks.')
@allowed([
  'AzureServices'
  'None'
])
param networkAclBypass string = 'AzureServices'

@description('Specifies whether disable the local authentication via API key.')
param disableLocalAuth bool = false

@description('Specifies the name of the Azure Cosmos DB database.')
param databaseName string

@description('Specifies the throughput of the Azure Cosmos DB database.')
param databaseThroughput int = 400

@description('Specifies the name of the Azure Cosmos DB container.')
param containerName string

@description('Specifies the IP rules for the Azure Cosmos DB database.')
param ipRules array = []

@description('Specifies the partition key of the container.')
param containerPartitionKey string = '/id'

@description('indexingMode	Indicates the indexing mode.')
@allowed([
  'consistent'
  'lazy'
  'none'
])
param indexingMode string = 'consistent'

@description('Specifies the object id of a Miccrosoft Entra ID user. In general, this the object id of the system administrator who deploys the Azure resources.')
param userObjectId string = ''

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
var logCategories = [
  'DataPlaneRequests'
  'MongoRequests'
  'QueryRuntimeStatistics'
  'PartitionKeyStatistics'
  'PartitionKeyRUConsumption'
  'ControlPlaneRequests'
  'CassandraRequests'
  'GremlinRequests'
  'TableApiRequests'
]
var metricCategories = [
  'Requests'
]
var logs = [for category in logCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: 0
  }
}]
var metrics = [for category in metricCategories: {
  category: category
  enabled: true
  retentionPolicy: {
    enabled: true
    days: 0
  }
}]

//********************************************
// Resources
//********************************************

resource account 'Microsoft.DocumentDB/databaseAccounts@2024-12-01-preview' = {
  name: toLower(accountName)
  kind: kind
  location: location
  tags: tags
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
    publicNetworkAccess: publicNetworkAccess
    networkAclBypass: networkAclBypass
    disableLocalAuth: disableLocalAuth
    ipRules: ipRules
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-12-01-preview' = {
  parent: account
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
    options: {
      throughput: databaseThroughput
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-12-01-preview' = {
  parent: database
  name: containerName
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          containerPartitionKey
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: indexingMode
        includedPaths: [
          {
            path: '/*'
          }
        ]
        excludedPaths: [
          {
            path: '/"_etag"/?'
          }
        ]
      }
    }
  }
}

resource cosmosDbOperatorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '230815da-be43-4aae-9cb4-875f7bd000aa'
  scope: subscription()
}

resource cosmosDbBuiltInDataContributorRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-05-15' existing = {
  parent: account
  name: '00000000-0000-0000-0000-000000000002'
}

resource cosmosDbOperatorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(userObjectId)) {
  name: guid(account.id, cosmosDbOperatorRoleDefinition.id, userObjectId)
  scope: account
  properties: {
    roleDefinitionId: cosmosDbOperatorRoleDefinition.id
    principalType: 'User'
    principalId: userObjectId
  }
}

resource cosmosDbBuiltInDataContributorRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-05-15' = if (!empty(userObjectId)) {
  parent: account
  name: guid(account.id, database.id, userObjectId, cosmosDbBuiltInDataContributorRoleDefinition.id)
  properties: {
    roleDefinitionId: cosmosDbBuiltInDataContributorRoleDefinition.id
    principalId: userObjectId
    scope: account.id
  }
}

resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: diagnosticSettingsName
  scope: account
  properties: {
    workspaceId: workspaceId
    logs: logs
    metrics: metrics
  }
}

//********************************************
// Outputs
//********************************************

output accountId string = account.id
output accountName string = account.name
output databaseId string = database.id
output databaseName string = database.name
output containerId string = container.id
output containerName string = container.name
output documentEndpoint string = account.properties.documentEndpoint
