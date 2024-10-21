#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <resource-group-name> <aks-cluster-name>"
  exit 1
fi

RESOURCE_GROUP=$1
AKS_CLUSTER_NAME=$2

# Set the AKS context for kubectl
echo "Setting the AKS context for kubectl..."
az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$AKS_CLUSTER_NAME"

# Deploy the pod
echo "Deploying pod to AKS..."
kubectl apply -f workloads/vn2/sample-pod.yaml

# Function to clean up resources
cleanup() {
  echo "Starting cleanup..."
  
  # Step 1: Delete the deployment
  echo "Deleting the deployment..."
  kubectl delete deployment --all --namespace=default
  
  # Step 2: Wait for pods to be deleted
  echo "Waiting for pods to be deleted..."
  while kubectl get pods --namespace=default | grep -q 'Running\|Pending\|ContainerCreating\|Terminating'; do
    echo "Pods are still terminating. Waiting for them to be deleted..."
    sleep 5
  done
  echo "All pods are deleted."
  
  # Step 3: Uninstall Helm release `vn2`
  echo "Uninstalling Helm release 'vn2'..."
  helm uninstall vn2
  
  # Step 4: Delete the virtual node `vn2-virtualnode-0`
  echo "Deleting the virtual node 'vn2-virtualnode-0'..."
  kubectl delete node vn2-virtualnode-0
  
  echo "Cleanup complete."
}

# Wait for pods to be in Running state
echo "Waiting for pods to be in Running state..."
end=$((SECONDS+180))  # 3 minutes timeout
ALL_PODS_RUNNING=false

while [ $SECONDS -lt $end ]; do
  POD_STATUSES=$(kubectl get pods --namespace=default --output=jsonpath='{.items[*].status.phase}')
  echo "Current pod statuses: $POD_STATUSES"
  
  # Convert statuses to an array
  IFS=' ' read -r -a POD_STATUS_ARRAY <<< "$POD_STATUSES"

  ALL_RUNNING=true
  for STATUS in "${POD_STATUS_ARRAY[@]}"; do
    if [[ "$STATUS" != "Running" ]]; then
      ALL_RUNNING=false
      break
    fi
  done

  if [[ "$ALL_RUNNING" == true ]]; then
    echo "All pods are in Running state."
    ALL_PODS_RUNNING=true
    break
  fi

  echo "Waiting for all pods to be in Running state..."
  sleep 10
done

if [[ "$ALL_PODS_RUNNING" == false ]]; then
  echo "Timeout reached. Pods did not reach Running state."
  cleanup
  exit 1  # Exit with failure after cleanup
fi

# If we reach here, the pods were successful, so proceed with cleanup
cleanup
exit 0  # Exit with success
