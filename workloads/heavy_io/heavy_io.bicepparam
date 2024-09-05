using './heavy_io.bicep'

param registry=''
// param cmd=['/bin/bash', 'workload_fio.sh']
param location=''

param ccePolicies = {
  heavy_io: ''
}
param managedIDName='cacidashboard'
