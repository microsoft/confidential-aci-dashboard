using './heavy_io.bicep'

param script='workload_fio'
param useNormalSidecar=''

// Image info
param registry='cacidashboard.azurecr.io'
param tag=''

// Deployment info
param location=''
param ccePolicies={
  heavy_io: ''
}
param managedIDName='cacidashboard'
