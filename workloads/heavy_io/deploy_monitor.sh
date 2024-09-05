#!/usr/bin/env bash

if [ -z "$MANUAL" ]; then
  MANUAL=0
fi

TARGET_PATH=`pwd`
PREFIX=`basename $TARGET_PATH`
TS=`date +'%Y%m%d-%H%M%S-%3N'`
DEPLOYMENT_NAME="$PREFIX-$TS"
RESOURCE_GROUP=tingmao-6.1-test
MANAGED_IDENTITY="tw61test-mid"
SUBSCRIPTION_ID=85c61f94-8912-4e82-900e-6ab44de9bdf8
# LOCATION=eastus2euap
LOCATION=westus

echo Deployment name: $DEPLOYMENT_NAME

function run_on() {
  local container_name="$1"
  local cmd="$2"
  echo Running \"$cmd\" on \"$container_name\" >&2
  az container exec \
    --container-name "$container_name" \
    -g "$RESOURCE_GROUP" \
    -n "$DEPLOYMENT_NAME" \
    --exec-command "$cmd"
  if [ $? -ne 0 ]; then
    echo "Failed to run command on $container_name"
    return 1
  fi
}

# c-aci-testing aci remove \
#     --deployment-name $DEPLOYMENT_NAME \
#     --resource-group $RESOURCE_GROUP \
#     --subscription $SUBSCRIPTION_ID || true

echo Running deployment

timeout -s INT 5m \
    c-aci-testing aci deploy $TARGET_PATH \
    --deployment-name $DEPLOYMENT_NAME \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --managed-identity $MANAGED_IDENTITY \
    --subscription $SUBSCRIPTION_ID
status=$?
failure_reason=""

if [ $status -eq 124 ]; then
  echo "Deployment timed out after 5m... Ignoring"
elif [ $status -ne 0 ]; then
  echo "Failed to deploy the workload"
  failure_reason="deploy"
fi

function do_checks() {
  local monitor_output=`c-aci-testing aci monitor \
      --deployment-name $DEPLOYMENT_NAME \
      --resource-group $RESOURCE_GROUP \
      --subscription $SUBSCRIPTION_ID`

  if [ $? -ne 0 ]; then
    failure_reason="monitor"
    return 1
  fi

  if [[ $monitor_output == "" ]]; then
    failure_reason="monitor"
    echo No output from monitor
    return 1
  fi

  run_on workload "ps -Af"
  if [ $? -ne 0 ]; then
    failure_reason="workload-cmd"
    return 1
  fi
  run_on workload "ls -la /dev/sev-guest"
  if [ $? -ne 0 ]; then
    failure_reason="workload-cmd"
    return 1
  fi
  run_on workload "uname -a"
  if [ $? -ne 0 ]; then
    failure_reason="workload-cmd"
    return 1
  fi

  local stdout=`run_on workload 'echo ok'`
  if [ $? -ne 0 ] || [[ $stdout != *"ok"* ]]; then
    echo "Failed to get back echo ok on workload"
    failure_reason="workload-cmd-echo"
    return 1
  fi
  local stdout=`run_on attestation 'echo ok'`
  if [ $? -ne 0 ] || [[ $stdout != *"ok"* ]]; then
    echo "Failed to get back echo ok on attestation"
    failure_reason="attestation-cmd-echo"
    return 1
  fi

  # sleep 30

  run_on workload dmesg | grep -i hv_storvsc
  # run_on attestation dmesg | grep -i hv_storvsc

  # local stdout=`run_on workload 'echo ok'`
  # if [ $? -ne 0 ] || [[ $stdout != *"ok"* ]]; then
  #   echo "Failed to get back echo ok on workload"
  #   failure_reason="workload-cmd-echo-postsleep"
  #   return 1
  # fi
  # local stdout=`run_on attestation 'echo ok'`
  # if [ $? -ne 0 ] || [[ $stdout != *"ok"* ]]; then
  #   echo "Failed to get back echo ok on attestation"
  #   failure_reason="attestation-cmd-echo-postsleep"
  #   return 1
  # fi
}

function write_loop_log() {
  local state="$1"
  echo "$state,$TS" >> loop.log
}

if [ "$failure_reason" == "" ]; then
  do_checks
  if [ $? -ne 0 ]; then
    echo "Failed check $failure_reason"
    write_loop_log "fail-$failure_reason"
  else
    echo "All checks passed"
    write_loop_log "success"
  fi
else
  write_loop_log "fail-$failure_reason"
fi

if [ "$MANUAL" -eq 1 ]; then
  echo Press any key to remove the deployment
  read -n 1
fi

c-aci-testing aci remove \
    --deployment-name $DEPLOYMENT_NAME \
    --resource-group $RESOURCE_GROUP \
    --subscription $SUBSCRIPTION_ID
