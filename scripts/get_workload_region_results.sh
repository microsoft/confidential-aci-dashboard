#!/bin/bash

workload=$1
region=$2

echo "Getting results for $workload workload in region: $region"

workflow_runs=$(gh run list \
    --workflow region-$region.yml \
    --branch main \
    --json databaseId \
    --jq '.[].databaseId' \
    --limit 99999)

success_count=0
failure_count=0

for run_id in $workflow_runs; do

    job_results=$(gh run view \
        $run_id \
        --json jobs \
        | jq -c -r --arg workload "$workload" \
            '[.jobs[] | select(.name | contains($workload))]')

    while IFS= read -r job_result; do
        conclusion=$(echo "$job_result" | jq -r '.conclusion')

        if [[ $conclusion == "success" ]]; then
            success_count=$((success_count + 1))

        elif [[ $conclusion == "failure" ]]; then
            url=$(echo "$job_result" | jq -r '.url')
            echo "Job failed:"
            echo "  Url: $url"
            echo "$job_result" | jq -c '.steps[]' | while IFS= read -r step_result; do
                step_conclusion=$(echo "$step_result" | jq -r '.conclusion')
                if [[ $step_conclusion == "failure" ]]; then
                    name=$(echo "$step_result" | jq -r '.name')
                    echo "  Step failed: $name"
                fi
            done
            failure_count=$((failure_count + 1))

        else
            echo "$name had uncovered conclusion: $conclusion"
            exit 1
        fi

    done < <(echo "$job_results" | jq -c '.[]')
done

echo "Success: ${success_count}"
echo "Failed: ${failure_count}"
echo "Success rate: $(awk "BEGIN {print $success_count / ($success_count + $failure_count) * 100}")%"