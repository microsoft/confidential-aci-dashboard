using './attestation.bicep'

// Image info
param registry=''
param tag=''

// Deployment info
param location='westeurope'
param ccePolicies={
  attestation: ''
}
param managedIDName='cacidashboard'
