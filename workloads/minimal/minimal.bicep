param location string
param ccePolicies object
param managedIDGroup string = resourceGroup().name
param managedIDName string

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
    ipAddress: {
      ports: [
        {
          protocol: 'TCP'
          port: 80
        }
      ]
      type: 'Public'
    }
    confidentialComputeProperties: {
      ccePolicy: ccePolicies.minimal
    }
    containers: [
      {
        name: 'primary'
        properties: {
          image: 'hello-world:latest'
          ports: [
            {
              protocol: 'TCP'
              port: 80
            }
          ]
          resources: {
            requests: {
              memoryInGB: 4
              cpu: 1
            }
          }
        }
      }
    ]
  }
}

output ids array = [containerGroup.id]
