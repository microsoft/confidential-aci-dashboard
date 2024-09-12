#!/bin/bash

gh_actions_run_id=$1
graphs_dir="results_$gh_actions_run_id"

scripts_dir=$(dirname "$(readlink -f "$0")")

mkdir -p $graphs_dir
(
    cd $graphs_dir

    gh run download $gh_actions_run_id
    find . -type f -name "*.html" -exec cp {} ./ \;

    $scripts_dir/create_homepage.sh

    python -m http.server
)