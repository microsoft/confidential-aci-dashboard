param location string
param ccePolicies object

param cpu int = 1
param memoryInGb int = 2

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: deployment().name
  location: location
  properties: {
    osType: 'Linux'
    sku: 'Confidential'
    restartPolicy: 'Never'
    confidentialComputeProperties: {
      ccePolicy: ccePolicies.ubuntu_22_04
    }
    containers: [
      {
        name: 'ubuntu'
        properties: {
          image: 'mcr.microsoft.com/mirror/docker/library/ubuntu:22.04'
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
