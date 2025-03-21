//********************************************
// Parameters
//********************************************

@description('Specifies the name prefix for all the Azure resources.')
@minLength(4)
@maxLength(10)
param prefix string = substring(uniqueString(resourceGroup().id), 0, 4)

@description('Specifies the name suffix or all the Azure resources.')
@minLength(4)
@maxLength(10)
param suffix string = substring(uniqueString(resourceGroup().id), 0, 4)

@description('Specifies the location for all the Azure resources.')
param location string = resourceGroup().location

@description('Specifies the name of the hosting plan.')
param hostingPlanName string = ''

@description('Specifies the tier name for the hosting plan.')
@allowed(
  [
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
  ]
)
param hostingPlanSkuTier string = 'ElasticPremium'

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
param hostingPlanSkuName string = 'EP1'

@description('Specifies the kind of the hosting plan.')
@allowed([
  'app'
  'elastic'
  'functionapp'
  'windows'
  'linux'
])
param hostingPlanKind string = 'elastic'

@description('Specifies whether the hosting plan is reserved.')
param hostingPlanIsReserved bool = true

@description('Specifies whether the hosting plan is zone redundant.')
param hostingPlanZoneRedundant bool = false

@description('Specifies a globally unique name for your deployed function app.')
param functionAppName string = ''

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
param functionAppKind string = 'functionapp,linux'

@description('Specifies the language runtime used by the function app.')
@allowed([
  'dotnet'
  'dotnet-isolated'
  'python'
  'java'
  'node'
  'powerShell'
  'custom'
])
param functionAppRuntimeName string = 'dotnet-isolated' 

@description('Specifies the target language version used by the function app.')
param functionAppRuntimeVersion string = '9.0' 

@description('Specifies whether the public network access is enabled or disabled')
@allowed([
  'Enabled'
  'Disabled'
])
param functionAppPublicNetworkAccess string = 'Enabled'

@description('Specifies the maximum scale-out instance count limit for the app.')
@minValue(40)
@maxValue(1000)
param functionAppMaximumInstanceCount int = 100

@description('Specifies the memory size of instances used by the app.')
@allowed([2048, 4096])
param functionAppInstanceMemoryMB int = 2048

@description('Specifies Azurre Functions extension verson.')
param extensionVersion string = '~4'

@description('Specifies allowed origins for client-side CORS request on the site.')
param allowedCorsOrigins string[] = []

@description('Specifies the name of the Azure Log Analytics resource.')
param logAnalyticsName string = ''

@description('Specifies the service tier of the workspace: Free, Standalone, PerNode, Per-GB.')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param logAnalyticsSku string = 'PerNode'

@description('Specifies the workspace data retention in days. -1 means Unlimited retention for the Unlimited Sku. 730 days is the maximum allowed for all other Skus.')
param logAnalyticsRetentionInDays int = 60

@description('Specifies the name of the Azure Application Insights resource.')
param applicationInsightsName string = ''

@description('Specifies wether deploying the Azure Key Vault resource.')
param deployKeyVault bool = true

@description('Specifies the name of the Azure Key Vault resource.')
param keyVaultName string = ''

@description('Specifies whether to allow public network access for Key Vault.')
@allowed([
  'Disabled'
  'Enabled'
])
param keyVaultPublicNetworkAccess string = 'Disabled'

@description('Specifies the default action of allow or deny when no other rules match for the Azure Key Vault resource. Allowed values: Allow or Deny')
@allowed([
  'Allow'
  'Deny'
])
param keyVaultNetworkAclsDefaultAction string = 'Allow'

@description('Specifies whether the Azure Key Vault resource is enabled for deployments.')
param keyVaultEnabledForDeployment bool = true

@description('Specifies whether the Azure Key Vault resource is enabled for disk encryption.')
param keyVaultEnabledForDiskEncryption bool = true

@description('Specifies whether the Azure Key Vault resource is enabled for template deployment.')
param keyVaultEnabledForTemplateDeployment bool = true

@description('Specifies whether the soft delete is enabled for this Azure Key Vault resource.')
param keyVaultEnableSoftDelete bool = true

@description('Specifies whether purge protection is enabled for this Azure Key Vault resource.')
param keyVaultEnablePurgeProtection bool = true

@description('Specifies whether enable the RBAC authorization for the Azure Key Vault resource.')
param keyVaultEnableRbacAuthorization bool = true

@description('Specifies the soft delete retention in days.')
param keyVaultSoftDeleteRetentionInDays int = 7

@description('Specifies the name for the Azure Storage Account resource.')
param storageAccountName string = ''

@description('Specifies whether to allow public network access for the storage account.')
@allowed([
  'Disabled'
  'Enabled'
])
param storageAccountPublicNetworkAccess string = 'Enabled'

@description('Specifies the access tier of the Azure Storage Account resource. The default value is Hot.')
param storageAccountAccessTier string = 'Hot'

@description('Specifies whether the Azure Storage Account resource allows public access to blobs.')
param storageAccountAllowBlobPublicAccess bool = true

@description('Specifies whether the Azure Storage Account resource allows shared key access.')
param storageAccountAllowSharedKeyAccess bool = true

@description('Specifies whether the Azure Storage Account resource allows cross-tenant replication.')
param storageAccountAllowCrossTenantReplication bool = false

@description('Specifies the minimum TLS version to be permitted on requests to the Azure Storage Account resource. The default value is TLS1_2.')
param storageAccountMinimumTlsVersion string = 'TLS1_2'

@description('The default action of allow or deny when no other rules match. Allowed values: Allow or Deny')
@allowed([
  'Allow'
  'Deny'
])
param storageAccountANetworkAclsDefaultAction string = 'Allow'

@description('Specifies whether the Azure Storage Account resource should only support HTTPS traffic.')
param storageAccountSupportsHttpsTrafficOnly bool = true

@description('Specifies whether to create containers.')
param storageAccountCreateContainers bool = false

@description('Specifies an array of containers to create.')
param storageAccountContainerNames array = []

@description('Specifies the name of the resource group hosting the virtual network and private endpoints.')
param virtualNetworkResourceGroupName string = resourceGroup().name

@description('Specifies the name of the virtual network.')
param virtualNetworkName string = ''

@description('Specifies the address prefixes of the virtual network.')
param virtualNetworkAddressPrefixes string = '10.0.0.0/8'

@description('Specifies the name of the subnet used by Azure Functions for the regional virtual network integration.')
param functionAppSubnetName string = 'FuncAppSubnet'

@description('Specifies the address prefix of the subnet used by Azure Functions for the regional virtual network integration.')
param functionAppSubnetAddressPrefix string = '10.0.0.0/24'

@description('Specifies the name of the subnet which contains private endpoints.')
param peSubnetName string = 'PeSubnet'

@description('Specifies the address prefix of the subnet which contains private endpoints.')
param peSubnetAddressPrefix string = '10.0.1.0/24'

@description('Specifies the name of the Azure NAT Gateway.')
param natGatewayName string = ''

@description('Specifies a list of availability zones denoting the zone in which Nat Gateway should be deployed.')
param natGatewayZones array = []

@description('Specifies the number of Public IPs to create for the Azure NAT Gateway.')
param natGatewayPublicIps int = 1

@description('Specifies the idle timeout in minutes for the Azure NAT Gateway.')
param natGatewayIdleTimeoutMins int = 30

@description('Specifies the name of the private endpoint to the blob storage account.')
param blobStorageAccountPrivateEndpointName string = ''

@description('Specifies the name of the private endpoint to the file storage account.')
param fileStorageAccountPrivateEndpointName string = ''

@description('Specifies the name of the private endpoint to the Key Vault.')
param keyVaultPrivateEndpointName string = ''

@description('Specifies the name of the Azure Cosmos DB account.')
param cosmosDbAccountName string = ''

@description('Specifies whether the public network access is enabled or disabled')
@allowed([
  'Enabled'
  'Disabled'
])
param cosmosDbAccountPublicNetworkAccess string = 'Enabled'

@description('Indicates what services are allowed to bypass firewall checks.')
@allowed([
  'AzureServices'
  'None'
])
param cosmosDbAccountNetworkAclBypass string = 'AzureServices'

@description('Specifies whether disable the local authentication via API key.')
param cosmosDbAccountDisableLocalAuth bool = false

@description('Specifies the name of the Azure Cosmos DB database.')
param cosmosDbDatabaseName string = 'DocumentDb'

@description('Specifies the name of the Azure Cosmos DB container.')
param cosmosDbContainerName string = 'DocumentCollection'

@description('Specifies the IP rules for the Azure Cosmos DB database.')
param cosmosDbIpRules array = []

@description('Specifies the name of the private endpoint to the Azure Cosmos DB.')
param cosmosDbPrivateEndpointName string = ''

@description('Specifies the name of the Azure OpenAI resource.')
param openAiName string = ''

@description('Specifies the location for all the Azure resources.')
param openAiLocation string = resourceGroup().location

@description('Specifies the resource model definition representing SKU.')
param openAiSku object = {
  name: 'S0'
}

@description('Specifies the identity of the OpenAI resource.')
param openAiIdentity object = {
  type: 'SystemAssigned'
}

@description('Specifies an optional subdomain name used for token-based authentication.')
param openAiCustomSubDomainName string = ''

@description('Specifies whether disable the local authentication via API key.')
param openAiDisableLocalAuth bool = false

@description('Specifies whether or not public endpoint access is allowed for this account..')
@allowed([
  'Enabled'
  'Disabled'
])
param openAiPublicNetworkAccess string = 'Enabled'

@description('Specifies the OpenAI deployments to create.')
param openAiDeployments array = []

@description('Specifies the name of the private link to the Azure OpenAI resource.')
param openAiPrivateEndpointName string = ''

@description('Specifies the name of the Azure OpenAI chat model deployment.')
param chatModelDeploymentName string

@description('Specifies the resource tags for all the resoources.')
param tags object = {}

@description('Specifies the object id of a Microsoft Entra ID user. In general, this the object id of the system administrator who deploys the Azure resources.')
param userObjectId string = ''

//********************************************
// Modules
//********************************************

module workspace 'modules/logAnalytics.bicep' = {
  name: 'workspace'
  params: {
    // properties
    name: empty(logAnalyticsName) ? toLower('${prefix}-log-analytics-${suffix}') : logAnalyticsName
    location: location
    tags: tags
    sku: logAnalyticsSku
    retentionInDays: logAnalyticsRetentionInDays
  }
}

module applicationInsights 'modules/applicationInsights.bicep' = {
  name: 'applicationInsights'
  params: {
    // properties
    name: empty(applicationInsightsName) ? toLower('${prefix}-app-insights-${suffix}') : applicationInsightsName
    location: location
    tags: tags
    workspaceId: workspace.outputs.id
  }
}

module keyVault 'modules/keyVault.bicep' = if (deployKeyVault) {
  name: 'keyVault'
  params: {
    // properties
    name: empty(keyVaultName) ? ('${prefix}-key-vault-${suffix}') : keyVaultName
    location: location
    tags: tags
    publicNetworkAccess: keyVaultPublicNetworkAccess
    networkAclsDefaultAction: keyVaultNetworkAclsDefaultAction
    enabledForDeployment: keyVaultEnabledForDeployment
    enabledForDiskEncryption: keyVaultEnabledForDiskEncryption
    enabledForTemplateDeployment: keyVaultEnabledForTemplateDeployment
    enablePurgeProtection: keyVaultEnablePurgeProtection
    enableRbacAuthorization: keyVaultEnableRbacAuthorization
    enableSoftDelete: keyVaultEnableSoftDelete
    softDeleteRetentionInDays: keyVaultSoftDeleteRetentionInDays
    workspaceId: workspace.outputs.id

    // role assignments
    userObjectId: userObjectId
  }
}

module storageAccount 'modules/storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    // properties
    name: empty(storageAccountName) ? toLower('${prefix}account${suffix}') : storageAccountName
    location: location
    tags: tags
    publicNetworkAccess: storageAccountPublicNetworkAccess
    accessTier: storageAccountAccessTier
    allowBlobPublicAccess: storageAccountAllowBlobPublicAccess
    allowSharedKeyAccess: storageAccountAllowSharedKeyAccess
    allowCrossTenantReplication: storageAccountAllowCrossTenantReplication
    minimumTlsVersion: storageAccountMinimumTlsVersion
    networkAclsDefaultAction: storageAccountANetworkAclsDefaultAction
    supportsHttpsTrafficOnly: storageAccountSupportsHttpsTrafficOnly
    workspaceId: workspace.outputs.id
    createContainers: storageAccountCreateContainers
    containerNames: storageAccountContainerNames
    
    // role assignments
    userObjectId: userObjectId
  }
}

module network './modules/virtualNetwork.bicep' = {
  name: 'network'
  scope: resourceGroup(virtualNetworkResourceGroupName)
  params: {
    name: empty(virtualNetworkName) ? toLower('${prefix}-vnet-${suffix}') : virtualNetworkName
    virtualNetworkAddressPrefixes: virtualNetworkAddressPrefixes
    delegationServiceName: hostingPlanSkuTier == 'FlexConsumption' ? 'Microsoft.App/environments' : 'Microsoft.Web/serverfarms'
    functionAppSubnetName: functionAppSubnetName
    functionAppSubnetAddressPrefix: functionAppSubnetAddressPrefix
    peSubnetName: peSubnetName
    peSubnetAddressPrefix: peSubnetAddressPrefix
    natGatewayName: empty(natGatewayName) ? toLower('${prefix}-nat-gateway-${suffix}') : natGatewayName
    natGatewayZones: natGatewayZones
    natGatewayPublicIps: natGatewayPublicIps
    natGatewayIdleTimeoutMins: natGatewayIdleTimeoutMins
    workspaceId: workspace.outputs.id
    location: location
    tags: tags
  }
}

module cosmosDb './modules/cosmosDb.bicep' = {
  name: 'cosmosDb'
  params: {
    accountName: empty(cosmosDbAccountName) ? toLower('${prefix}-cosmos-db-${suffix}') : cosmosDbAccountName
    networkAclBypass: cosmosDbAccountNetworkAclBypass
    publicNetworkAccess: cosmosDbAccountPublicNetworkAccess
    disableLocalAuth: cosmosDbAccountDisableLocalAuth
    databaseName: cosmosDbDatabaseName
    containerName: cosmosDbContainerName
    ipRules: cosmosDbIpRules
    userObjectId: userObjectId
    workspaceId: workspace.outputs.id
    location: location
    tags: tags
  }
}

module openAi './modules/openAi.bicep' = {
  name: 'openAi'
  params: {
    name: empty(openAiName) ? toLower('${prefix}-open-ai-${suffix}') : openAiName
    sku: openAiSku
    identity: openAiIdentity
    customSubDomainName: empty(openAiCustomSubDomainName) ? empty(openAiName) ? toLower('${prefix}-open-ai-${suffix}') : openAiName : openAiCustomSubDomainName
    disableLocalAuth: openAiDisableLocalAuth
    publicNetworkAccess: openAiPublicNetworkAccess
    deployments: openAiDeployments
    userObjectId: userObjectId
    workspaceId: workspace.outputs.id
    location: openAiLocation
    tags: tags
  }
}

module privateEndpoints './modules/privateEndpoints.bicep' = {
  name: 'privateEndpoints'
  scope: resourceGroup(virtualNetworkResourceGroupName)
  params: {
    subnetId: network.outputs.peSubnetId
    blobStorageAccountPrivateEndpointName: empty(blobStorageAccountPrivateEndpointName)
      ? toLower('${prefix}-blob-storage-pe-${suffix}')
      : blobStorageAccountPrivateEndpointName
    fileStorageAccountPrivateEndpointName: empty(fileStorageAccountPrivateEndpointName)
      ? toLower('${prefix}-file-storage-pe-${suffix}')
      : fileStorageAccountPrivateEndpointName
    keyVaultPrivateEndpointName: empty(keyVaultPrivateEndpointName)
      ? toLower('${prefix}-key-vault-pe-${suffix}')
      : keyVaultPrivateEndpointName
    openAiPrivateEndpointName: empty(openAiPrivateEndpointName)
      ? toLower('${prefix}-open-ai-pe-${suffix}')
      : openAiPrivateEndpointName
    cosmosDbPrivateEndpointName: empty(cosmosDbPrivateEndpointName)
      ? toLower('${prefix}-cosmos-db-pe-${suffix}')
      : cosmosDbPrivateEndpointName
    storageAccountId: storageAccount.outputs.id
    keyVaultId: keyVault.outputs.id
    openAiId: openAi.outputs.id
    cosmosDbAccountId: cosmosDb.outputs.accountId
    location: location
    tags: tags
  }
}

module serverFarm './modules/serverFarm.bicep' = {
  name: 'serverFarm'
  params: {
    // properties
    name: empty(hostingPlanName) ? toLower('${prefix}-hosting-plan-${suffix}') : hostingPlanName
    location: location
    tags: tags
    skuTier: hostingPlanSkuTier
    skuName: hostingPlanSkuName
    kind: hostingPlanKind
    zoneRedundant: hostingPlanZoneRedundant
    workspaceId: workspace.outputs.id
    isReserved: hostingPlanIsReserved
  }
}

module managedIdentity './modules/managedIdentity.bicep' = {
  name: 'managedIdentity'
  params: {
    // properties
    name: empty(functionAppName) ? toLower('${prefix}-function-app-${suffix}-identity') : '${functionAppName}-identity'
    storageAccountName: storageAccount.outputs.name
    applicationInsightsName: applicationInsights.outputs.name
    openAiName: openAi.outputs.name
    accountName: cosmosDb.outputs.accountName
    databaseName: cosmosDb.outputs.databaseName
    location: location
    tags: tags
  }
}

module functionApp './modules/functionApp.bicep' = {
  name: 'functionApp'
  params: {
    // properties
    name: empty(functionAppName) ? toLower('${prefix}-function-app-${suffix}') : functionAppName
    kind: functionAppKind
    runtimeName: functionAppRuntimeName
    runtimeVersion: functionAppRuntimeVersion
    allowedCorsOrigins: allowedCorsOrigins
    publicNetworkAccess: functionAppPublicNetworkAccess
    extensionVersion: extensionVersion
    instanceMemoryMB: functionAppInstanceMemoryMB
    maximumInstanceCount: functionAppMaximumInstanceCount
    managedIdentityName: managedIdentity.outputs.name
    hostingPlanName: serverFarm.outputs.name
    applicationInsightsName: applicationInsights.outputs.name
    storageAccountName: storageAccount.outputs.name
    openAiName: openAi.outputs.name
    chatModelDeploymentName: chatModelDeploymentName
    accountName: cosmosDb.outputs.accountName
    databaseName: cosmosDb.outputs.databaseName
    containerName: cosmosDb.outputs.containerName
    virtualNetworkName: network.outputs.name
    subnetName: functionAppSubnetName
    location: location
    tags: tags
  }
}

//********************************************
// Outputs
//********************************************

output deploymentInfo object = {
  subscriptionId: subscription().subscriptionId
  resourceGroupName: resourceGroup().name
  location: location
  storageAccountName: storageAccount.outputs.name
}
