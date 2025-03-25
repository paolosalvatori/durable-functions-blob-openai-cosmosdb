#!/bin/bash

# This script fetches documents from an Azure Cosmos DB collection using the REST API
# The script requires the Azure CLI and jq to be installed
# The script uses the Azure CLI to fetch an access token for the Cosmos DB resource
# The access token is used for authentication in the request
# This script requires the user to be logged in to the Azure CLI and have the necessary role assignments:
# - Control plane: Cosmos DB Operator on the Azure Cosmos DB account
# - Data plane: Cosmos DB Built-in Data Contributor on the Azure Cosmos DB database

# The name of the Azure Cosmos DB account
accountName="<YOUR_COSMOS_DB_ACCOUNT_NAME>"

# The name of the database in the Azure Cosmos DB account
databaseName="DocumentDb"

# The name of the collection (container) in the database
collectionName="DocumentCollection"

# The URL to access the documents in the specified collection
docsUrl="https://$accountName.documents.azure.com/dbs/$databaseName/colls/$collectionName/docs"

# Fetch an access token using Azure CLI for the Cosmos DB resource
# The token is used for authentication in the request
accessToken=$(az account get-access-token --resource "https://$accountName.documents.azure.com" --query accessToken -o tsv)

# Use curl to send a GET request to the Cosmos DB documents endpoint
# -X GET: Specifies the HTTP GET method
# -H: Adds headers for authorization, content type, and API version
# jq: Formats the JSON response for better readability
curl -X GET "$docsUrl" \
  -H "Authorization: type=aad&ver=1.0&sig=$accessToken" \
  -H "Content-Type: application/json" \
  -H "x-ms-version: 2018-12-31" | jq