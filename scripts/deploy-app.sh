#!/bin/bash

# Define variables
FUNCTION_APP_NAME="<YOUR_FUNCTION_APP_NAME>"
RESOURCE_GROUP_NAME="<YOUR_RESOURCE_GROUP_NAME>"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/../code/project"

# Navigate to the project directory
cd $PROJECT_DIR

# Publish the Azure Function
func azure functionapp publish $FUNCTION_APP_NAME --resource-group $RESOURCE_GROUP_NAME