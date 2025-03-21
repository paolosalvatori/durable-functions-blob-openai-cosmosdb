using './main.bicep'

param prefix = 'nova' // The prefix must be at least 4 characters long
param suffix = 'test' // The prefix must be at least 4 characters long
param userObjectId = '<YOUR_USER_OBJECT_ID>' // The object id of your user in Microsoft Entra ID
param keyVaultEnablePurgeProtection = false
param storageAccountCreateContainers = true
param storageAccountContainerNames = [
  'input'
  'output'
]
param cosmosDbIpRules = [] 
param openAiLocation = '<YOUR_FAVORITE_AZURE_LOCATION>'
param openAiDeployments = [
  {
    model: {
      name: 'gpt-4o'
      version: '2024-05-13'
    }
    sku: {
      name: 'GlobalStandard'
      capacity: 10
    }
  }
]
param chatModelDeploymentName = 'gpt-4o'
param tags = {
  environment: 'development'
  iac: 'bicep'
}
