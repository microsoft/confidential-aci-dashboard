using './attestation.bicep'

// Image info
param tag='2.7'

// Deployment info
param location='westeurope'
param ccePolicies={
  attestation: ''
}
param managedIDName='cacidashboard'
