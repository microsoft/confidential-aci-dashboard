using './server.bicep'

// Image info
param registry=''
param managedIDName=''

// Deployment info
param location=''
param ccePolicies={
  server: ''
}
