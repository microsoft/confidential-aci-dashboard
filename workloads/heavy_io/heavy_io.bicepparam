using './heavy_io.bicep'

// param cmd=['/bin/bash', 'workload_fio.sh']

// Image info
param registry='cacidashboard.azurecr.io'

// Deployment info
param location=''
param ccePolicies={
  heavy_io: ''
}
param managedIDName='cacidashboard'
