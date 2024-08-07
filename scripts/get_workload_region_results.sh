#!/bin/bash

workload=$1
region=$2
since=$3

echo "Getting results for:"
echo "  Workload: $workload"
echo "  Region: $region"
if [[ "$since" != "" ]]; then
    echo "  Since: $since"
fi

success_count=0
failure_count=0

parse_jobs() {
    job_results=$1

    while IFS= read -r job_result; do
        conclusion=$(echo "$job_result" | jq -r '.conclusion')
        url=$(echo "$job_result" | jq -r '.url')

        if [[ "$since" != "" ]]; then
            startedAt=$(echo "$job_result" | jq -r '.startedAt')
            startedAtTS=$(date -d "$startedAt" +%s)
            sinceTs=$(date -d "$since" +%s)
            if [[ $startedAtTS -lt $sinceTs ]]; then
                continue
            fi
        fi

        if [[ $conclusion == "success" ]]; then
            echo -e "\e[32m✓\e[0m Success: $url"
            success_count=$((success_count + 1))

        elif [[ $conclusion == "failure" ]]; then
            date=$(echo "$job_result" | jq -r '.completedAt')
            echo -e "\e[31m✗\e[0m Failure: $url"
            echo "  Run ID: $run_id"
            echo "  Date: $date"
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
}

# Check region workloads
workflow_runs=$(gh run list \
    --workflow region-$region.yml \
    --branch main \
    --json databaseId \
    --jq '.[].databaseId' \
    --limit 99999)
for run_id in $workflow_runs; do
    job_results=$(gh run view \
        $run_id \
        --json jobs \
        | jq -c -r --arg workload "$workload" \
            '[.jobs[] | select(.name | contains($workload))]')
    parse_jobs "$job_results"
done

# Check workload runs
workflow_runs=$(gh run list \
    --workflow workload-$workload.yml \
    --branch main \
    --json databaseId \
    --jq '.[].databaseId' \
    --limit 99999)
for run_id in $workflow_runs; do
    location=$(gh run view $run_id --log 2>/dev/null \
        | grep "Setting parameter location to" \
        | sed -n "s/.*'\(.*\)'.*/\1/p")
    if [[ $location == $region ]]; then
        job_results=$(gh run view $run_id --json jobs | jq -c -r '[.jobs[]]')
        parse_jobs "$job_results"
    fi
done

echo "Success: ${success_count}"
echo "Failed: ${failure_count}"
echo "Success rate: $(awk "BEGIN {print $success_count / ($success_count + $failure_count) * 100}")%"
