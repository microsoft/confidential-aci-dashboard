param location string
param registry string
param tag string
param ccePolicies object
param managedIDGroup string = resourceGroup().name
param managedIDName string

param cpu int = 1
param memoryInGb int = 2

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: deployment().name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId(managedIDGroup, 'Microsoft.ManagedIdentity/userAssignedIdentities', managedIDName)}': {}
    }
  }
  properties: {
    osType: 'Linux'
    sku: 'Confidential'
    restartPolicy: 'Never'
    imageRegistryCredentials: [
      {
        server: registry
        identity: resourceId(managedIDGroup, 'Microsoft.ManagedIdentity/userAssignedIdentities', managedIDName)
      }
    ]
    confidentialComputeProperties: {
      ccePolicy: ccePolicies.long_lived
    }
    containers: [
      {
        name: 'ubuntu'
        properties: {
          image: '${registry}/ubuntu:${empty(tag) ? 'latest': tag}'
          command: [
            'sh'
            '-c'
            'sleep infinity'
          ]
          resources: {
            requests: {
              memoryInGB: memoryInGb
              cpu: cpu
            }
          }
        }
      }
    ]
  }
}

output ids array = [containerGroup.id]
