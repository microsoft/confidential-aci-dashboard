param location string
param registry string
param tag string
param ccePolicies object
param managedIDGroup string = resourceGroup().name
param managedIDName string

param cpu int = 1
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
    imageRegistryCredentials: [
      {
        server: registry
        identity: resourceId(managedIDGroup, 'Microsoft.ManagedIdentity/userAssignedIdentities', managedIDName)
      }
    ]
    confidentialComputeProperties: {
      ccePolicy: ccePolicies.attestation
    }
    containers: [
      {
        name: 'proxy'
        properties: {
          image: '${registry}/nginx:latest'
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
            '/bin/sh', '-c'
            'echo "server { listen 8000; location / { proxy_pass http://localhost:8080; } }" > /etc/nginx/conf.d/default.conf && nginx -g "daemon off;"'
          ]
        }
      }
      {
        name: 'attestation'
        properties: {
          image: 'mcr.microsoft.com/aci/skr:${empty(tag) ? 'latest': tag}'
          ports: [
            {
              protocol: 'TCP'
              port: 8080
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
