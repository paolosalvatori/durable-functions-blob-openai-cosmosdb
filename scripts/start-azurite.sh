#!/bin/bash

# This script starts an Azure Storage emulator (Azurite) for local development and testing.
azurite --silent --location /mnt/d/azurite --debug /mnt/d/azurite/debug.log --blobPort 10000 --queuePort 10001 --tablePort 10002