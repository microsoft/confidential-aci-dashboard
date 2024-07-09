param location string
param ccePolicies object

param cpu int = 1
param memoryInGb int = 4

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: deployment().name
  location: location
  properties: {
    osType: 'Linux'
    sku: 'Confidential'
    restartPolicy: 'Never'
    confidentialComputeProperties: {
      ccePolicy: ccePolicies.many_layers
    }
    containers: [
      {
        name: 'primary'
        properties: {
          image: 'mcr.microsoft.com/devcontainers/cpp:jammy'
          command: [
            'bash'
            '-c'
            'echo "Many layers"'
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
