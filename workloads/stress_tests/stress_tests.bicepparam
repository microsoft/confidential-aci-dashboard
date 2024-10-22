using './stress_tests.bicep'

param script='workload_fio'
param useNormalSidecar=true

// Image info
param registry='cacidashboard.azurecr.io'
param tag=''

// Deployment info
param location=''
param ccePolicies={
  stress_tests: ''
}
param managedIDName='cacidashboard'
