using './heavy_io.bicep'

param registry='tingmaotest'

// Python workload
param workloadImgRef='tingmaotest.azurecr.io/payload-test'

// Squashed workload
// param workloadImgRef='tingmaotest.azurecr.io/payload-test:squashed'

// Many layers workload
// param workloadImgRef='tingmaotest.azurecr.io/payload-test:25'

// Nginx workload
// param workloadImgRef='cacidashboard.azurecr.io/nginx:1.26'

/////////////////////////

// Python workload command
// param workloadCmd = 'python payload.py'

// Heavy workload command
param workloadCmd='echo \'payload sleep then tar\' > /dev/kmsg; while :; do sleep 1; echo alive at `date`; done & sleep 0.5; while :; do tar -c /{bin,etc,home,lib,opt,payload,root,sbin,usr,var} > /dev/null 2>/dev/null || exit 1; done'

// Nginx workload command
// param workloadCmd='echo "server { listen 8000; location / { proxy_pass http://localhost:8080; } }" > /etc/nginx/conf.d/default.conf && nginx -g "daemon off;"'

param skrTag='2.7'

// Deployment info
param location='eastus2euap'
// allow all policy
param ccePolicy = 'cGFja2FnZSBwb2xpY3kKCmFwaV92ZXJzaW9uIDo9ICIwLjEwLjAiCmZyYW1ld29ya192ZXJzaW9uIDo9ICIwLjMuMCIKCm1vdW50X2RldmljZSA6PSB7ImFsbG93ZWQiOiB0cnVlfQptb3VudF9vdmVybGF5IDo9IHsiYWxsb3dlZCI6IHRydWV9CmNyZWF0ZV9jb250YWluZXIgOj0geyJhbGxvd2VkIjogdHJ1ZSwgImVudl9saXN0IjogbnVsbCwgImFsbG93X3N0ZGlvX2FjY2VzcyI6IHRydWV9CnVubW91bnRfZGV2aWNlIDo9IHsiYWxsb3dlZCI6IHRydWV9CnVubW91bnRfb3ZlcmxheSA6PSB7ImFsbG93ZWQiOiB0cnVlfQpleGVjX2luX2NvbnRhaW5lciA6PSB7ImFsbG93ZWQiOiB0cnVlLCAiZW52X2xpc3QiOiBudWxsfQpleGVjX2V4dGVybmFsIDo9IHsiYWxsb3dlZCI6IHRydWUsICJlbnZfbGlzdCI6IG51bGwsICJhbGxvd19zdGRpb19hY2Nlc3MiOiB0cnVlfQpzaHV0ZG93bl9jb250YWluZXIgOj0geyJhbGxvd2VkIjogdHJ1ZX0Kc2lnbmFsX2NvbnRhaW5lcl9wcm9jZXNzIDo9IHsiYWxsb3dlZCI6IHRydWV9CnBsYW45X21vdW50IDo9IHsiYWxsb3dlZCI6IHRydWV9CnBsYW45X3VubW91bnQgOj0geyJhbGxvd2VkIjogdHJ1ZX0KZ2V0X3Byb3BlcnRpZXMgOj0geyJhbGxvd2VkIjogdHJ1ZX0KZHVtcF9zdGFja3MgOj0geyJhbGxvd2VkIjogdHJ1ZX0KcnVudGltZV9sb2dnaW5nIDo9IHsiYWxsb3dlZCI6IHRydWV9CmxvYWRfZnJhZ21lbnQgOj0geyJhbGxvd2VkIjogdHJ1ZX0Kc2NyYXRjaF9tb3VudCA6PSB7ImFsbG93ZWQiOiB0cnVlfQpzY3JhdGNoX3VubW91bnQgOj0geyJhbGxvd2VkIjogdHJ1ZX0K'

param managedIDName='tw61test-mid'
