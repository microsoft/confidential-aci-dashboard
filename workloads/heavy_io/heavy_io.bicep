param location string
param registry string
param tag string
param managedIDGroup string = resourceGroup().name
param managedIDName string
param ccePolicies object
param script string = 'workload_fio'

param cpu int = 4
param memoryInGb int = 4

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
    restartPolicy: 'Never' // Detect container crashes
    ipAddress: {
      ports: [
        {
          protocol: 'TCP'
          port: 8000
        }
      ]
      type: 'Public'
    }
    imageRegistryCredentials: [
      {
        server: registry
        identity: resourceId(managedIDGroup, 'Microsoft.ManagedIdentity/userAssignedIdentities', managedIDName)
      }
    ]
    confidentialComputeProperties: {
      ccePolicy: ccePolicies.heavy_io
    }
    containers: [
      {
        name: 'workload'
        properties: {
          image: '${registry}/heavy_io/workload:${tag}'
          ports: [
            {
              protocol: 'TCP'
              port: 8000
            }
          ]
          environmentVariables: [
            {
              name: 'PORT'
              value: '8000'
            }
          ]
          resources: {
            requests: {
              memoryInGB: memoryInGb
              cpu: cpu
            }
          }
          command: [
            '/bin/bash'
            '${script}.sh'
          ]
        }
      }
      {
        name: 'sidecar'
        properties: {
          image: '${registry}/heavy_io/sidecar:${tag}'
          ports: [
            {
              protocol: 'TCP'
              port: 8080
            }
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