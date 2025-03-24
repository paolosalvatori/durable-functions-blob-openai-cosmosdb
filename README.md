# Create a Simple AI Data Pipeline with Azure Durable Functions

This sample demonstrates how to build a data pipeline using [Azure Durable Functions](https://learn.microsoft.com/azure/azure-functions/durable/durable-functions-overview). The pipeline performs the following tasks:

1. Reads questions from a JSON file dropped as a blob in an [Azure Storage Account](https://learn.microsoft.com/azure/storage/common/storage-account-overview).
2. Sends the questions to an [Azure OpenAI Service](https://learn.microsoft.com/azure/ai-services/openai/overview) chat model for processing.
3. Stores the processed results as individual documents in an [Azure Cosmos DB](https://learn.microsoft.com/azure/cosmos-db/introduction) database.

This repository includes:

- A collection of [Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/overview?tabs=bicep) templates to deploy the required Azure infrastructure.
- The Azure Functions application code written in C#.

You can use the following buttons to deploy or visualize the Azure resources used by the solution:

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fdurable-functions-blob-openai-cosmosdb%2Fbicep%2Fazuredeploy.json)
[![Visualize](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fdurable-functions-blob-openai-cosmosdb%2Fbicep%2Fazuredeploy.json)


