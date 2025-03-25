#!/bin/bash

# This script fetches documents from an Azure Cosmos DB collection using the REST API with a SQL query.
# Prerequisites:
# - Azure CLI and jq must be installed.
# - The user must be logged into Azure CLI and have the necessary role assignments:
#   - Control plane: Cosmos DB Operator on the Azure Cosmos DB account.
#   - Data plane: Cosmos DB Built-in Data Contributor on the Azure Cosmos DB database.

# The name of the Azure Cosmos DB account
accountName="<YOUR_COSMOS_DB_ACCOUNT_NAME>"

# The name of the database in the Azure Cosmos DB account
databaseName="DocumentDb"

# The name of the collection (container) in the database
collectionName="DocumentCollection"

# Replace with your SQL query
sqlQuery="SELECT c.request, c.response FROM c WHERE CONTAINS(LOWER(c.request), 'capital')" #Example query

# Construct the URL to access the documents in the specified collection
docsUrl="https://$accountName.documents.azure.com/dbs/$databaseName/colls/$collectionName/docs"

# Fetch an access token using Azure CLI for the Cosmos DB resource
accessToken=$(az account get-access-token --resource "https://$accountName.documents.azure.com" --query accessToken -o tsv)

# Construct the request body with the SQL query
requestBody='{"query": "'"$sqlQuery"'", "parameters": []}' #The parameters array is used for parameterized queries.

# Use curl to send a POST request to the Cosmos DB documents endpoint with the SQL query
curl -X POST "$docsUrl" \
  -H "Authorization: type=aad&ver=1.0&sig=$accessToken" \
  -H "Content-Type: application/query+json" \
  -H "Accept: application/json" \
  -H "x-ms-documentdb-isquery: True" \
  -H "x-ms-version: 2018-12-31" \
  -H "x-ms-query-enable-crosspartition: True" \
  -H "x-ms-documentdb-query-enablecrosspartition: True" \
  -H "x-ms-date: $(date -u +"%a, %d %b %Y %H:%M:%S GMT")" \
  -d "$requestBody" | jq