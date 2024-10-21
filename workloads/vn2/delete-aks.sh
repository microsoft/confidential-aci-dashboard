#!/bin/bash

# Take input for RESOURCE_GROUP and AKS_CLUSTER_NAME
echo "Enter RESOURCE_GROUP:"
read RESOURCE_GROUP
echo "Enter AKS_CLUSTER_NAME:"
read AKS_CLUSTER_NAME

# Install Azure CLI if not already installed
# Check for Azure CLI
if ! [ -x "$(command -v az)" ]; then
  echo "Azure CLI not found. Installing Azure CLI..."
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
else
  echo "Azure CLI is already installed."
fi

# Set Azure account subscription
az account set --subscription 85c61f94-8912-4e82-900e-6ab44de9bdf8
if [ $? -ne 0 ]; then
  echo "Failed to set Azure subscription. Exiting..."
  exit 1
fi  

# Deleting the AKS Cluster
echo "Deleting AKS cluster '$AKS_CLUSTER_NAME' in resource group '$RESOURCE_GROUP'..."

az aks delete --resource-group "$RESOURCE_GROUP" --name "$AKS_CLUSTER_NAME" --yes --no-wait

if [ $? -eq 0 ]; then
    echo "AKS cluster deletion initiated successfully."
    echo "It may take a few minutes for the cluster to be fully deleted."
else
    echo "Failed to initiate AKS cluster deletion."
    exit 1
fi

# Wait for the cluster deletion to complete before proceeding (optional)
echo "Waiting for the AKS cluster deletion to complete (this may take several minutes)..."
az aks wait --deleted --name "$AKS_CLUSTER_NAME" --resource-group "$RESOURCE_GROUP"

# Deleting the Resource Group
echo "Deleting the resource group '$RESOURCE_GROUP' and all its associated resources..."

az group delete --name "$RESOURCE_GROUP" --yes --no-wait

if [ $? -eq 0 ]; then
    echo "Resource group deletion initiated successfully."
    echo "It may take several minutes for all resources to be fully deleted."
else
    echo "Failed to initiate resource group deletion."
    exit 1
fi


