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

        elif [[ $conclusion == "failure" || $conclusion == "cancelled" ]]; then
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
            '[.jobs[] | select(.name | endswith($workload))]')
    parse_jobs "$job_results"
done

# Check workload runs
workflow_runs=$(gh run list \
    --workflow workload-$workload.yml \
    --branch main \
    --json databaseId \
    --jq '.[].databaseId' \
    --limit 99999)

any_locations_found=false

for run_id in $workflow_runs; do

    # Location is provided as in input to the workflow so you would assume
    # finding the workflow run inputs and checking the value of location would
    # be the best way to find the location.
    #
    # However these are not provided in the github actions API as far as I can
    # see, neither is the workflow defined environment variables I could also
    # check.
    #
    # Therefore the only way I can find to get the location is to fetch all logs
    # and look for the log that sets the bicepparam parameter for location.
    #
    # THIS COULD BREAK IF WE STOP LOGGING THAT IN THIS WAY IN C-ACI-TESTING
    #
    # It also means that runs which don't get as far as setting this, don't get
    # found, this is an okay tradeoff only because we're interested in runs that
    # got to the step of deploying, if they didn't get that far something else
    # broke that is our responsibility not ACI's
    location=$(gh run view $run_id --log 2>/dev/null \
        | grep "Setting parameter location to" \
        | sed -n "s/.*'\(.*\)'.*/\1/p")

    if [[ $location == $region ]]; then
        any_locations_found=true
        job_results=$(gh run view $run_id --json jobs | jq -c -r '[.jobs[]]')
        parse_jobs "$job_results"
    fi
done

if [[ $any_locations_found == false ]]; then
    echo "No runs of specific workflow found for location, see code for explanation"
    echo "Might be genuine if the workload specific workflow is only run in a "
    echo "region via the region workflow, otherwise it's only run in westeurope"
fi

echo "Success: ${success_count}"
echo "Failed: ${failure_count}"
echo "Success rate: $(awk "BEGIN {print $success_count / ($success_count + $failure_count) * 100}")%"
