using './long_lived.bicep'

// Image info
param registry=''
param tag=''

// Deployment info
param location=''
param ccePolicies={}
param managedIDName=''
