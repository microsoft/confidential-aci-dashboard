#!/bin/bash

workload=$1
region=$2
count=$3

echo "Running workload multiple times:"
echo "  Workload: $workload"
echo "  Region: $region"
echo "  Count: $count"

base_id=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)

for ((i=1; i<=$count; i++)); do
    gh workflow run workload-$workload.yml \
        -f id=$base_id-$i \
        -f location=$region
done