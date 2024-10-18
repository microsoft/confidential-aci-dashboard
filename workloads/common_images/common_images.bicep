param location string
param ccePolicies object

param cpu int = 1
param memoryInGb int = 2

var common_images = [
  'mcr.microsoft.com/mirror/docker/library/ubuntu:22.04'
  'mcr.microsoft.com/mirror/docker/library/ubuntu:24.04'
]

func imageName(image string) string => replace(replace(split(image, '/')[length(split(image, '/'))-1], ':', ''), '.', '')

resource containerGroups 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = [for (image, idx) in common_images: {
  name: '${deployment().name}-${imageName(image)}'
  location: location
  properties: {
    osType: 'Linux'
    sku: 'Confidential'
    restartPolicy: 'Never'
    confidentialComputeProperties: {
      ccePolicy: ccePolicies['common_images_${imageName(image)}']
    }
    containers: [
      {
        name: imageName(image)
        properties: {
          image: image
          command: [
            '/bin/bash'
            '-c'
            'echo "Container ${imageName(image)} Started"'
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
}]

output ids array = [for (image, idx) in common_images: containerGroups[idx].id]
