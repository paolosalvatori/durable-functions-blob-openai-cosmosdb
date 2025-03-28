#!/bin/bash

# This script uploads a file to the local Azure Storage Emulator (Azurite) using the Azure CLI.

# Variables
accountName="devstoreaccount1"
accountKey="Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw=="
containerName="input"
filePath="../documents/geography.json"
blobEndpoint="http://127.0.0.1:10000/$accountName"

# Generate a timestamp in the format YYYY-MM-DD-HH-MM-SS
timestamp=$(date +"%Y-%m-%d-%H-%M-%S")

# Extract the file name and extension
fileName=$(basename -- "$filePath")
fileBaseName="${fileName%.*}" # File name without extension
fileExtension="${fileName##*.}" # File extension

# Construct the blob name with the timestamp
blobName="${fileBaseName}-${timestamp}.${fileExtension}"

# Check whether the container already exists
containerExists=$(az storage container exists \
  --name $containerName \
  --account-name $accountName \
  --account-key $accountKey \
  --blob-endpoint $blobEndpoint | jq .exists)

if [ $containerExists == "true" ]; then
  echo "Container '$containerName' already exists."
else
  echo "Container '$containerName' does not exist."

  # Create the container if it doesn't exist
  az storage container create \
    --name $containerName \
    --account-name $accountName \
    --account-key $accountKey \
    --blob-endpoint $blobEndpoint
fi

# Upload the file to the container
az storage blob upload \
  --container-name $containerName \
  --file $filePath \
  --name $blobName \
  --account-name $accountName \
  --account-key $accountKey \
  --blob-endpoint $blobEndpoint

echo "File uploaded successfully to Azurite with blob name: $blobName"