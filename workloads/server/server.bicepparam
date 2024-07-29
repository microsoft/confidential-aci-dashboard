using './server.bicep'

// Image info
param tag=''

// Deployment info
param location=''
param ccePolicies={
  server: ''
}
