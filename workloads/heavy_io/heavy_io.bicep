param location string
param registry string
param workloadImgRef string
param workloadCmd string
param skrTag string
param managedIDGroup string = resourceGroup().name
param managedIDName string
param ccePolicy string

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
    restartPolicy: 'Never'
    ipAddress: {
      ports: [
        {
          protocol: 'TCP'
          port: 8000
        }
      ]
      type: 'Public'
    }
    // imageRegistryCredentials: [
    //   {
    //     server: registry
    //     identity: resourceId(managedIDGroup, 'Microsoft.ManagedIdentity/userAssignedIdentities', managedIDName)
    //   }
    // ]
    confidentialComputeProperties: {
      ccePolicy: ccePolicy
    }
    containers: [
      {
        name: 'workload'
        properties: {
          image: workloadImgRef
          ports: [
            {
              protocol: 'TCP'
              port: 8000
            }
          ]
          environmentVariables: [
            {
              name: 'NGINX_PORT'
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
            '/bin/bash', '-c'
            workloadCmd
          ]
        }
      }
      {
        name: 'attestation'
        properties: {
          image: 'mcr.microsoft.com/aci/skr:${empty(skrTag) ? 'latest': skrTag}'
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
